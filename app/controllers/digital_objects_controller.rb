# encoding: utf-8

class DigitalObjectsController < ApplicationController
  before_action :set_digital_object, only: [:show, :edit, :update, :destroy, :undestroy, :data_for_ordered_child_editor, :download, :add_parent, :remove_parents, :mods, :media_view, :rotate_image, :swap_order_of_first_two_child_assets]
  before_action :set_digital_object_for_data_for_editor_action, only: [:data_for_editor]
  before_action :set_contextual_nav_options
  before_action :set_var_digital_object_data_or_render_error, only: [:create, :update]
  before_action :require_appropriate_project_permissions!

  # GET /digital_objects
  # GET /digital_objects.json
  def index
  end
  
  def set_var_digital_object_data_or_render_error
    if params[:digital_object_data_json].blank?
      render json: { success: false, errors: ['Missing param digital_object_data_json'] } and return
      false
    else
      @digital_object_data = convert_digital_object_data_json(params[:digital_object_data_json])
      true
    end
  end

  # POST /digital_objects
  # POST /digital_objects.json
  def create
    if @digital_object_data['digital_object_type'].blank?
      render json: { success: false, errors: ['Missing digital_object_data_json[digital_object_type]'] } and return
    end
    
    begin
      @digital_object = DigitalObjectType.get_model_for_string_key(@digital_object_data['digital_object_type']['string_key']).new()
    rescue Hyacinth::Exceptions::InvalidDigitalObjectTypeError
      render json: { success: false, errors: ['Invalid digital_object_type specified: digital_object_type => ' + @digital_object_data['digital_object_type'].inspect] } and return
    end
    
    # We need to do two things here for Asset uploads:
    # 1) Make sure that non-admins can only do uploads via post data or upload directory
    # 2) Transform @digital_object_data['import_file'] value for post data uploads so that we reference the temp file that Rails created during the upload.
    if @digital_object.is_a?(DigitalObject::Asset)
      if @digital_object_data['import_file'].blank?
        render json: { success: false, errors: ['Missing digital_object_data_json[import_file] for new Asset'] } and return
      end
      
      import_type = @digital_object_data['import_file']['import_type']
      if import_type.blank?
        render json: { success: false, errors: ['Missing digital_object_data_json[import_file][import_type] for new Asset'] } and return
      end
      
      if (! current_user.is_admin?) && import_type != DigitalObject::Asset::IMPORT_TYPE_POST_DATA && import_type != DigitalObject::Asset::IMPORT_TYPE_UPLOAD_DIRECTORY
        render json: { success: false, errors: ['Only admins can perform file imports of type: ' + import_type] } and return
      end
      
      # Now we'll transform @digital_object_data['import_file'] if this is a post data upload
      if import_type == DigitalObject::Asset::IMPORT_TYPE_POST_DATA
        
        if params[:file].blank?
          render json: { success: false, errors: ['An attached file is required in the request data for imports of type: ' + import_type] } and return
        end
        
        # Immediately unlink the uploaded file.  This is recommended for POSIX systems,
        # but the code below should still work on non-POSIX systems (like Windows).
        # Why do we do this?  Cleans up temp files as quickly as possible so they
        # don't wait around to be garbage collected.  With lots of file uploads,
        # accumulation of too many temp files could be problematic.
        # Recommended here: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tempfile/rdoc/Tempfile.html (See: "Unlink after creation")
        # And here: http://docs.ruby-lang.org/en/2.1.0/Tempfile.html (See: "Unlink-before-close")
        upload = params[:file]
        
        @digital_object_data['import_file'] = {
          'import_type' => DigitalObject::Asset::IMPORT_TYPE_POST_DATA,
          'import_path' => upload.tempfile.path,
          'original_file_path' => upload.original_filename
        }
      end
    end
    
    success = false
    
    begin
    
      begin
        @digital_object.set_digital_object_data(@digital_object_data, false)
      rescue Hyacinth::Exceptions::NotFoundError, Hyacinth::Exceptions::MalformedControlledTermFieldValue => e
        render json: { success: false, errors: [e.message] } and return
      end
      
      @digital_object.created_by = current_user
      @digital_object.updated_by = current_user
  
      test_mode = params['test'].to_s == 'true'
      do_publish = !test_mode && params['publish'].to_s == 'true'
      
      success = (test_mode ? @digital_object.valid? : @digital_object.save) && (do_publish ? @digital_object.publish : true)
    
    ensure
      # If we're dealing with a file upload (which isn't always the case), make sure to close the file when we're done
      if params[:file].present?
        params[:file].tempfile.close
        params[:file].tempfile.unlink
      end
    end

    if success
      render json: {
        success: true,
        pid: @digital_object.pid
      }.merge(@digital_object.is_a?(DigitalObject::Asset) ? {
        'uploaded_file_confirmation' => {
          'name' => @digital_object.get_original_filename,
          'size' => @digital_object.get_file_size_in_bytes,
          'errors' => @digital_object.errors.full_messages
        }
      } : {})
    else
      render json: {
        errors: @digital_object.errors
      }
    end
    
  end
  
  # DELETE /digital_objects/1
  # DELETE /digital_objects/1.json
  def destroy
    respond_to do |format|
      if @digital_object.destroy
        format.json {
          render json: {
            success: true
          }
        }
      else
        format.json {
          render json: {
            errors: @digital_object.errors
          }
        }
      end
    end
  end

  # PATCH/PUT /digital_objects/1
  # PATCH/PUT /digital_objects/1.json
  def update
    # Default behavior is to merge dynamic fields by default, unless told not to.
    if params['merge_dynamic_fields'].present? && params['merge_dynamic_fields'].to_s == 'false'
      merge_dynamic_fields = false
    else
      merge_dynamic_fields = true
    end
    
    begin
      @digital_object.set_digital_object_data(@digital_object_data, merge_dynamic_fields)
    rescue Hyacinth::Exceptions::NotFoundError, Hyacinth::Exceptions::MalformedControlledTermFieldValue => e
      render json: { success: false, errors: [e.message] } and return
    end
    
    @digital_object.updated_by = current_user

    test_mode = params['test'].to_s == 'true'
    do_publish = !test_mode && params['publish'].to_s == 'true'

    respond_to do |format|
      if (test_mode ? @digital_object.valid? : @digital_object.save) && (do_publish ? @digital_object.publish : true)
        format.json {
          render json: {
            success: true,
            pid: @digital_object.pid
          }
        }
      else
        format.json {
          render json: {
            errors: @digital_object.errors
          }
        }
      end
    end
  end

  # PUT /digital_objects/1/undelete.json
  def undestroy

    @digital_object.state = 'A'

    respond_to do |format|
      if @digital_object.save
        format.json {
          render json: {
            success: true
          }
        }
      else
        format.json {
          render json: {
            errors: @digital_object.errors
          }
        }
      end
    end
  end

  def data_for_editor
    project = @digital_object.project
    fieldsets = Fieldset.where(project: project)
    enabled_dynamic_fields = @digital_object.get_enabled_dynamic_fields
    
    dynamic_field_hierarchy = DynamicFieldGroupCategory.all # Get all DyanamicFieldGroupCategories (which recursively includes sub-dynamic_field_groups and dynamic_fields)
    dynamic_field_ids_to_enabled_dynamic_fields = Hash[enabled_dynamic_fields.map{|enabled_dynamic_field| [enabled_dynamic_field.dynamic_field_id, enabled_dynamic_field]}]

    data_for_editor_response = {
      digital_object: @digital_object,
      dynamic_field_hierarchy: dynamic_field_hierarchy,
      fieldsets: fieldsets,
      dynamic_field_ids_to_enabled_dynamic_fields: dynamic_field_ids_to_enabled_dynamic_fields,
      allowed_publish_targets: @digital_object.allowed_publish_targets.map{|pub| {display_label: pub.display_label, pid: pub.pid} }
    }

    if params['search_result_number'].present? && params['search'].present?
      current_result_number = params['search_result_number'].to_i
      search_params = params['search']

      previous_result_pid, next_result_pid, total_num_results = DigitalObject::Base.get_previous_and_next_in_search(current_result_number, search_params)

      data_for_editor_response['previous_and_next_data'] = {}
      data_for_editor_response['previous_and_next_data']['previous_pid'] = previous_result_pid
      data_for_editor_response['previous_and_next_data']['next_pid'] = next_result_pid
      data_for_editor_response['previous_and_next_data']['total_num_results'] = total_num_results
    end

    respond_to do |format|
      format.json {
        render json: data_for_editor_response
      }
    end

  end
  
  def search_results_to_csv
    
    csv_export = CsvExport.create(
      user: current_user,
      search_params: JSON.generate(params['search'].present? ? params['search'] : {})
    )
    
    Hyacinth::Queue::export_search_results_to_csv(csv_export.id)
    
    respond_to do |format|
      format.json {
        render json: {
          success: true,
          csv_export_id: csv_export.id
        }
      }
    end
  end
  
  def search
    respond_to do |format|
      format.json {

        search_response = DigitalObject::Base.search(
          params['search'].present? ? params['search'] : {},
          params['facet'].present? ? params['facet'] : {},
          current_user
        )
        if params['include_single_field_searchable_field_list'] && params['include_single_field_searchable_field_list'].to_s == 'true'
          search_response['single_field_searchable_fields'] = Hash[ DynamicField.where(is_single_field_searchable: true).order([:standalone_field_label, :string_key]).map{|dynamic_field| [dynamic_field.string_key, dynamic_field.standalone_field_label]} ]
        end
        render json: search_response
        
      }
    end
  end
  
  def titles_for_pids
    
    respond_to do |format|
      format.json {
        render json: DigitalObject::Base.titles_for_pids(params[:pids].blank? ? [] : params[:pids], current_user)
      }
    end
  end

  # GET /digital_objects/cul:123.json
  def show
    respond_to do |format|
      format.json {
        render json: @digital_object
      }
    end
  end

  def mods

    xml_output = @digital_object.render_xml_datastream(XmlDatastream.find_by(string_key: 'descMetadata'))

    respond_to do |format|
      format.xml {
        render text: xml_output, content_type: 'text/xml'
      }
    end
  end

  def download
    if @digital_object.is_a?(DigitalObject::Asset)
      send_file @digital_object.get_filesystem_location, filename: @digital_object.get_original_filename
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
  end

  # A view for image zooming, video players, audio players, etc.
  def media_view
    raise 'This view is only available for assets.' unless @digital_object.is_a?(DigitalObject::Asset)
    render layout: 'content_only'
  end

  def data_for_ordered_child_editor

    ordered_child_search_results = []

    if @digital_object.ordered_child_digital_object_pids.present?
      child_pids = @digital_object.ordered_child_digital_object_pids
      
      pids_to_search_results = {}
      search_response = DigitalObject::Base.search({'pids' => child_pids, 'per_page' => 99999}, false, current_user)
      if search_response['results'].present?
        search_response['results'].each do |result|
          pids_to_search_results[result['pid']] = result
        end
      end
      
      child_pids.each do |pid|
        ordered_child_search_results.push(pids_to_search_results[pid].present? ? pids_to_search_results[pid] : {'pid' => pid})
      end
      
    end

    respond_to do |format|
      format.json {
        render json: {
          digital_object: @digital_object,
          ordered_child_search_results: ordered_child_search_results,
          too_many_to_show: false # We are always showing all children.  Might change this later if this becomes a problem.
        }
      }
    end

  end

  def add_parent

    test_mode = params['test'].present? && params['test'].to_s == 'true'
    errors = []
    
    if @digital_object.pid == params[:parent_pid]
      errors << "An object cannot be its own parent.  That's crazy!"
    end
    
    if @digital_object.parent_digital_object_pids.include?(params[:parent_pid])
      errors << 'Object already has parent: ' + params[:parent_pid]
    end
    
    if errors.blank?
      begin
        parent_digital_object = DigitalObject::Base.find(params[:parent_pid])
        
        # If child is Asset, then parent must be Item
        # If child is Item or Group, then parent must be Group
        if @digital_object.is_a?(DigitalObject::Asset)
          errors << "Parent must be an Item or FileSystem" unless parent_digital_object.is_a?(DigitalObject::Item) || parent_digital_object.is_a?(DigitalObject::FileSystem)
        else
          errors << "Parent must be a Group"
        end  
        
        unless errors.present? || test_mode
          @digital_object.add_parent_digital_object(parent_digital_object)
          @digital_object.save
        end
        
      rescue Hyacinth::Exceptions::DigitalObjectNotFoundError
        errors << 'Could not find Digital Object with PID: ' + params[:parent_pid]
      end
      
    end

    errors += @digital_object.errors.to_a
    
    if errors.present?
      response = {
        success: false,
        errors: errors
      }
    else
      response = {
        success: true
      }
    end

    respond_to do |format|
      format.json {
        render json: response
      }
    end
  end
  
  def remove_parents

    test_mode = params['test'].present? && params['test'].to_s == 'true'
    errors = []
    
    errors << 'You must specify at least one pid to remove.' if params[:parent_pids].blank?
    
    if errors.blank?
      begin
        params[:parent_pids].each do |pid|
          parent_digital_object = DigitalObject::Base.find(pid)
          @digital_object.remove_parent_digital_object(parent_digital_object)
        end
        
        unless errors.present? || test_mode
          @digital_object.save
        end
      rescue Hyacinth::Exceptions::DigitalObjectNotFoundError
        errors << 'Could not find Digital Object with PID: ' + params[:parent_pid]
      end
      
    end

    errors += @digital_object.errors.to_a
    
    if errors.present?
      response = {
        success: false,
        errors: errors
      }
    else
      response = {
        success: true
      }
    end

    respond_to do |format|
      format.json {
        render json: response
      }
    end
  end

  def rotate_image

    errors = []
    if @digital_object.is_a?(DigitalObject::Asset) && @digital_object.dc_type == 'StillImage'
      rotate_by = params[:rotate_by].to_i
      @digital_object.fedora_object.orientation -= rotate_by
      unless @digital_object.save && @digital_object.regenrate_image_derivatives!
        errors << 'An error occurred during image regeneration.'
      end
    else
      errors << "Only Assets of type StillImage can be rotated.  This is a #{@digital_object.digital_object_type.display_label} of type #{@digital_object.dc_type}"
    end

    if errors.present?
      render json: {errors: errors}
    else
      render json: {success: true}
    end

  end

  def swap_order_of_first_two_child_assets
    errors = []
    if @digital_object.is_a?(DigitalObject::Item) && @digital_object.ordered_child_digital_object_pids.length == 2
      @digital_object.ordered_child_digital_object_pids = @digital_object.ordered_child_digital_object_pids.reverse
      unless @digital_object.save
        errors << 'An error occurred during image regeneration.'
      end
    else
      errors << "Only Items with 2 child assets can have have their first two assets swapped.  This is a #{@digital_object.digital_object_type.display_label} with #{@digital_object.ordered_child_digital_object_pids.length} child assets."
    end

    if errors.present?
      render json: {errors: errors}
    else
      render json: {success: true, ordered_child_digital_object_pids: @digital_object.ordered_child_digital_object_pids}
    end
  end
  
  def upload_directory_listing
    
    directory_path = params[:directory_path] || ''
    errors = []
			
    #Return a directory listing for the specified directory within mod/assets
    
    #For safety, don't allow file paths with ".." in them.
    #If we encounter this, change the entire directoryPath to an empty string.
    if directory_path.index("..") != nil
      directory_path = ""
      errors << "Paths are not allowed to contain \"..\""
    end
    
    #Get list of files contained within directory_path
    full_path_to_directory = File.join(HYACINTH['upload_directory'], directory_path)
    entries = Dir.entries(full_path_to_directory)
    
    directory_data = []
    entries.each do |entry|
      next if entry == '.' || entry == '..'
      entry_to_add = {}
      entry_to_add['name'] = entry
      entry_to_add['isDirectory'] = File.directory?(File.join(full_path_to_directory, entry))
      entry_to_add['path'] = directory_path + '/' + entry
      directory_data << entry_to_add
    end
        
    response = {}
    response["errors"] = errors if errors.present?
    response["directoryData"] = directory_data
    
    render json: response
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_digital_object
    @digital_object = DigitalObject::Base.find(params[:id])
  end
  
  def set_digital_object_for_data_for_editor_action
    if params[:pid]
      # A DigitalObject pid is expected when we're working with an existing DigialObject
      @digital_object = DigitalObject::Base.find(params[:pid])
    elsif params[:project_string_key]
      # A DigitalObject id is not available when we're working with a new item, so we expect a project_id and digital_object_type_id instead
      project = Project.find_by(string_key: params[:project_string_key])
      digital_object_type = DigitalObjectType.find_by(string_key: params[:digital_object_type_string_key])
      # Return an empty DigitalObject instance with the correct project
      @digital_object = DigitalObjectType.get_model_for_string_key(digital_object_type.string_key).new
      @digital_object.project = project
    end
  end

  def set_contextual_nav_options
    @contextual_nav_options['nav_title']['label'] = 'Digital Objects'
  end

  def require_appropriate_project_permissions!
    case params[:action]
    when 'index', 'search', 'upload_directory_listing', 'titles_for_pids'
      # Do nothing.  These actions are open to all logged-in users.
    when 'show', 'data_for_editor', 'mods', 'download', 'data_for_ordered_child_editor', 'media_view'
      require_project_permission!(@digital_object.project, :read)
    when 'create'
      # Access logic inside action method
      project_find_criteria = @digital_object_data['project'] # i.e. {string_key: 'proj'} or {pid: 'abc:123'}
      associated_project = Project.find_by(project_find_criteria)
      require_project_permission!(associated_project, :create)
      # Also require publish permission if params[:publish] is set to true
      require_project_permission!(associated_project, :publish) if params[:publish].to_s == 'true'
    when 'update', 'reorder_child_digital_objects', 'add_parent', 'remove_parents', 'rotate_image', 'swap_order_of_first_two_child_assets'
      require_project_permission!(@digital_object.project, :update)
      # Also require publish permission if params[:publish] is set to true (note: applies to the 'update' action)
      require_project_permission!(@digital_object.project, :publish) if params[:publish].to_s == 'true'
    when 'destroy', 'undestroy'
      require_project_permission!(@digital_object.project, :delete)
    else
      require_hyacinth_admin!
    end
  end
  
  def convert_digital_object_data_json(digital_object_data_json)
    # Convert json-encoded digital_object_data_json to hash
    # Note: We submit digital_object_data to the API as JSON to preserve array order, since http param order isn't guaranteed
    unless digital_object_data_json.nil?
      raise 'Invalid JSON given for digital_object_data_json' unless Hyacinth::Utils::JsonUtils.valid_json?(digital_object_data_json)
      return JSON.parse(digital_object_data_json)
    end
  end

  # Handles a file upload and returns a hash with information about the upload.
  # Hash format: {'name' => 'file.tif', size => '12345', errors => ['Some error']}
  #
  # param import_type: Valid values
  def handle_single_file_upload(original_file_path, import_type, file_to_upload, project, parent_digital_object)

    file_size = file_to_upload.size

    upload_response = {
      "name" => original_file_path,
      "size" => file_size,
      "errors" => []
    }

    valid_import_types = ['internal', 'external']
    unless valid_import_types.include?(import_type)
      upload_response['errors'] = ['Param import_type must be one of: ' + valid_import_types.join(', ')]
      return upload_response
    end

    new_asset_digital_object = DigitalObject::Asset.new
    new_asset_digital_object.project = project
    new_asset_digital_object.add_parent_digital_object(parent_digital_object) if parent_digital_object.present?
    new_asset_digital_object.set_title('', File.basename(original_file_path))

    # Save new_asset_digital_object so that we can get a pid that we'll use to place the uploaded file in the right place
    if new_asset_digital_object.save

      if import_type == 'internal'

        # Generate checksum for original file -- before copy -- using 4096-byte buffered approach to save memory for large files
        original_file_sha256 = Digest::SHA256.new
        while buff = file_to_upload.read(4096)
          original_file_sha256.update(buff)
        end
        original_file_sha256_hexdigest = original_file_sha256.hexdigest
        file_to_upload.rewind # seek back to start of file for future reading

        # Copy file to final asset destination directory
        path_to_final_save_location = Hyacinth::Utils::PathUtils.path_to_asset_file(new_asset_digital_object.pid, new_asset_digital_object.project, File.basename(original_file_path))

        if File.exists?(path_to_final_save_location)
          upload_response['errors'] << 'Pre-file-write test unexpectedly found existing file at target location: ' + path_to_final_save_location
        else
          # Recursively make necessary directories
          FileUtils.mkdir_p(File.dirname(path_to_final_save_location))
  
          # Test write abilities
          FileUtils.touch(path_to_final_save_location)
          unless File.exists?(path_to_final_save_location)
            upload_response['errors'] << 'Unable to write to file path: ' + path_to_final_save_location
          else
            # Using a write buffer of 4096 bytes so that we don't use too much memory when copying large files.
            # 'w' == write, 'b' == binary mode
            File.open(path_to_final_save_location, 'wb') do |file|
              while buff = file_to_upload.read(4096)
                file.write(buff)
              end
            end
          end
        end

      elsif import_type == 'external'
        path_to_final_save_location = original_file_path
      end

      new_asset_digital_object.set_file_and_file_size_and_original_file_path_and_calculate_checksum(path_to_final_save_location, original_file_path, file_size)

      # If internal file, confirm that new checksum matches old checksum.  Return error if not.
      if import_type == 'internal'
        original_file_checksum = 'SHA-256:' + original_file_sha256_hexdigest
        final_copy_file_checksum = new_asset_digital_object.get_checksum
        if original_file_checksum != final_copy_file_checksum
          upload_response['errors'] << "Error during file copy.  Copied file checksum (#{final_copy_file_checksum}) doesn't match original (#{original_file_checksum}).  Delete uploaded record and try again."
        return upload_response
        end
      end

      new_asset_digital_object.save
    end

    upload_response['errors'] = new_asset_digital_object.errors if new_asset_digital_object.errors.present?

    return upload_response

  end

end
