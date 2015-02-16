# encoding: utf-8

class DigitalObjectsController < ApplicationController
  before_action :set_digital_object, only: [:show, :edit, :update, :destroy, :undestroy, :data_for_ordered_child_editor, :download, :add_parent, :mods, :media_view]
  before_action :set_contextual_nav_options

  # GET /digital_objects
  # GET /digital_objects.json
  def index
  end

  def search
    respond_to do |format|
      format.json {

        search_response = DigitalObject::Base.search(params['search'].present? ? params['search'] : {}, params['facet'].present? ? params['facet'] : {})
        if params['include_single_field_searchable_field_list'] && params['include_single_field_searchable_field_list'].to_s == 'true'
          search_response['single_field_searchable_fields'] = Hash[ DynamicField.where(is_single_field_searchable: true).order([:standalone_field_label, :string_key]).map{|dynamic_field| [dynamic_field.string_key, dynamic_field.standalone_field_label]} ]
        end
        render json: search_response
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
      send_file @digital_object.get_filesystem_location
    else
      render text: @digital_object.digital_object_type.display_label.pluralize + ' do not have download URLs.  Try downloading an Asset instead.'
    end
  end

  # A view for image zooming, video players, audio players, etc.
  def media_view
    raise 'This view is only available for assets.' unless @digital_object.is_a?(DigitalObject::Asset)
    render layout: 'content_only'
  end

  # POST /digital_objects
  # POST /digital_objects.json
  def create

    test_mode = params['test'].present? && params['test'].to_s == 'true'

    project = Project.find_by(string_key: digital_object_params['project_string_key'])
    digital_object_type = DigitalObjectType.find_by(string_key: digital_object_params['digital_object_type_string_key'])

    class_to_instantiate = digital_object_type.get_associated_model
    @digital_object = class_to_instantiate.new
    @digital_object.created_by = current_user
    @digital_object.updated_by = current_user
    @digital_object.projects << project

    unless digital_object_params['dynamic_field_data_json'].nil?
      #dynamic_field_data_json = Hyacinth::Utils::StringUtils.clean_utf8_string(digital_object_params['dynamic_field_data_json'])
      dynamic_field_data_json = digital_object_params['dynamic_field_data_json']
      raise 'Invalid JSON given for dynamic_field_data_json' unless Hyacinth::Utils::JsonUtils.is_valid_json?(dynamic_field_data_json)
      @digital_object.update_dynamic_field_data(JSON(dynamic_field_data_json))
    end

    if digital_object_params['parent_digital_object_pid']
      parent_digital_object = DigitalObject::Base.find(digital_object_params['parent_digital_object_pid'])
      @digital_object.add_parent_digital_object(parent_digital_object)
    end

    respond_to do |format|
      if (test_mode ? @digital_object.valid? : @digital_object.save)
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

  # PATCH/PUT /digital_objects/1
  # PATCH/PUT /digital_objects/1.json
  def update

    test_mode = params['test'].present? && params['test'] == 'true'

    if digital_object_params['dynamic_field_data_json'].present?
      raise 'Invalid JSON given for dynamic_field_data_json' unless Hyacinth::Utils::JsonUtils.is_valid_json?(digital_object_params['dynamic_field_data_json'])
      @digital_object.update_dynamic_field_data(JSON(digital_object_params['dynamic_field_data_json']))
    end

    if digital_object_params['ordered_child_digital_object_pids']

      # First verify that the incoming list of ordered_child_digital_object_pids
      # includes the same values as the existing list (ignoring order).  This is
      # not a place for adding or removing values -- just reordering them.
      # Return an error if the lists differ.

      unless @digital_object.ordered_child_digital_object_pids.length == (@digital_object.ordered_child_digital_object_pids | digital_object_params['ordered_child_digital_object_pids']).length
        @digital_object.errors.add(:ordered_child_digital_object_pids, ' - During reordering, sent child digital object pids must match existing pids.')
      else
        digital_object_params['ordered_child_digital_object_pids'].each do |pid|
          unless @digital_object.ordered_child_digital_object_pids.include?(pid)
            child_digital_object = DigitalObject::Base.find(pid)
            child_digital_object.add_parent_digital_object(@digital_object)
            child_digitial_object.save
          end
        end
        @digital_object.ordered_child_digital_object_pids = digital_object_params['ordered_child_digital_object_pids']
      end
    end

    @digital_object.updated_by = current_user

    respond_to do |format|
      if (test_mode ? @digital_object.valid? : @digital_object.save)
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

  def data_for_editor

    if params[:pid]
      # A DigitalObject pid is expected when we're working with an existing DigialObject
      @digital_object = DigitalObject::Base.find(params[:pid])
      projects = @digital_object.projects
      digital_object_type = @digital_object.digital_object_type

      fieldsets = Fieldset.where(project: projects)
      enabled_dynamic_fields = @digital_object.get_enabled_dynamic_fields
    elsif params[:project_string_key]
      # A DigitalObject id is not available when we're working with a new item, so we expect a project_id and digital_object_type_id instead
      project = Project.find_by(string_key: params[:project_string_key])
      digital_object_type = DigitalObjectType.find_by(string_key: params[:digital_object_type_string_key])

      fieldsets = Fieldset.where(project: project)
      enabled_dynamic_fields = project.get_enabled_dynamic_fields(digital_object_type)

      # Return an empty DigitalObject instance with the project

      @digital_object = digital_object_type.get_associated_model().new
      @digital_object.projects << project
    end

    dynamic_field_hierarchy = DynamicFieldGroupCategory.all # Get all DyanamicFieldGroupCategories (which recursively includes sub-dynamic_field_groups and dynamic_fields)
    dynamic_field_ids_to_enabled_dynamic_fields = Hash[enabled_dynamic_fields.map{|enabled_dynamic_field| [enabled_dynamic_field.dynamic_field_id, enabled_dynamic_field]}]

    data_for_editor_response = {
      digital_object: @digital_object,
      dynamic_field_hierarchy: dynamic_field_hierarchy,
      fieldsets: fieldsets,
      dynamic_field_ids_to_enabled_dynamic_fields: dynamic_field_ids_to_enabled_dynamic_fields,
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

  def data_for_ordered_child_editor

    max_number_of_child_assets_to_load = 20 # More than this would be unreasonably slow to load (at least right now).
                                            # We don't want to return a partial set because this is used for ordering.

    too_many_to_show = false

    if @digital_object.ordered_child_digital_object_pids.blank?
      ordered_child_digital_objects = []
    else
      child_pids = @digital_object.ordered_child_digital_object_pids
      if child_pids.length <= max_number_of_child_assets_to_load
        ordered_child_digital_objects = child_pids.map{|pid|DigitalObject::Base.find(pid)}
      else
        ordered_child_digital_objects = []
        too_many_to_show = true
      end
    end


    respond_to do |format|
      format.json {
        render json: {
          digital_object: @digital_object,
          ordered_child_digital_objects: ordered_child_digital_objects,
          too_many_to_show: too_many_to_show
        }
      }
    end

  end

  def upload_assets

    test_mode = params['test'].present? && params['test'].to_s == 'true'

    overall_errors = []

    if params['parent_digital_object_pid']
      puts 'parent retrieval 1'
      parent_digital_object = DigitalObject::Base.find(params['parent_digital_object_pid'])

      # Only DigitalObject::Item objects can have child assets
      unless parent_digital_object.is_a?(DigitalObject::Item)
        overall_errors << "You can only upload assets to a parent Digital Object of type Item.  Object with pid #{parent_digital_object.pid} is of type: #{parent_digital_object.digital_object_type.display_label}"
      end

      projects = parent_digital_object.projects
    elsif params['project_string_key'].present?
      parent_digital_object = nil
      project = Project.find_by(string_key: params['project_string_key'])
      if project.present?
        projects = [project]
      else
        overall_errors << "Could not find project for string key: #{params['project_string_key']}"
      end
    else
      overall_errors << "Missing project string key.  Supply param project_string_key OR referene a parent digital object."
    end


    file_data = []

    if overall_errors.present?
      file_data << {
        "name" => 'Error',
        "size" => 0,
        "errors" => overall_errors
      }
    # Case 1: We're receiving file data from an HTTP upload
    elsif params['files'].present?

      # Immediately unlink all files.  This is recommended for POSIX systems,
      # but the code below should still work on non-POSIX systems (like Windows).
      # Why do we do this?  Cleans up temp files as quickly as possible so they
      # don't wait around to be garbage collected.  With lots of file uploads,
      # accumulation of too many temp files could be problematic.
      # Recommended here: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tempfile/rdoc/Tempfile.html (See: "Unlink after creation")
      # And here: http://docs.ruby-lang.org/en/2.1.0/Tempfile.html (See: "Unlink-before-close")

      params['files'].each {|uploaded_file|
        uploaded_file.tempfile.unlink # On Windows, this silently fails.  That's okay.  We still need to use a begin/ensure clause with file.tempfile.close.
      }

      params['files'].each do |uploaded_file|
        begin

          # Check for invalid characters in filename.  Reject if non-utf8.
          # If we get weird characters (like "\xC2"), Ruby will die a horrible death.  Let's keep Ruby alive.
          if uploaded_file.original_filename != Hyacinth::Utils::StringUtils.clean_utf8_string(uploaded_file.original_filename)
            file_data << {
              "name" => uploaded_file.original_filename,
              "size" => uploaded_file.tempfile.size,
              "errors" => ["Invalid UTF-8 characters found in filename.  Unable to upload."]
            }
          else
            original_file_path = '' # For now, always blank for HTTP file uploads
            original_filename = uploaded_file.original_filename

            if test_mode
              puts 'Test mode output: Would have created new Asset for: ' + uploaded_file.original_filename
            else
              file_data << handle_single_file_upload(original_filename, original_file_path, 'internal', uploaded_file.tempfile, projects, parent_digital_object)
            end
          end
        ensure
           uploaded_file.tempfile.close!  # Closes the file handle. If the file wasn't unlinked earlier
                                # because #unlink failed, then this method will attempt
                                # to do so again.
        end
      end

    elsif params['local_filesystem_file_path']

      # Case 2: We're receiving file data from a local filesystem location.

      original_file_path = params['local_filesystem_file_path'].to_s
      original_filename = File.basename(original_file_path)

      # Check for invalid characters in filename.  Reject if non-utf8.
      # If we get weird characters (like "\xC2"), Ruby will die a horrible death.  Let's keep Ruby alive.
      if original_file_path != Hyacinth::Utils::StringUtils.clean_utf8_string(original_file_path)
        file_data << {
          "name" => original_file_path,
          "size" => 0,
          "errors" => ["Invalid UTF-8 characters found in file path.  Unable to upload."]
        }
      else
        # Make sure that the file actually exists
        unless File.exists?(original_file_path)
          file_data << {
            "name" => original_file_path,
            "size" => 0,
            "errors" => ["No file found at path: " + original_file_path]
          }
        end

        if test_mode
          puts 'Test mode output: Would have created new Asset for file at: ' + original_file_path
        else
          # 'r' == read, 'b' == binary mode
          File.open(original_file_path, 'rb') do |file|
            file_data << handle_single_file_upload(original_filename, original_file_path, params['import_type'], file, projects, parent_digital_object)
          end

          if params['import_type'] == 'internal' && file_data.last['errors'].blank?
            # Since this was an internal upload, we copied the file to some Hyacinth-asset-directory location.
            # If we're here, the save (i.e. file copy) went through without a problem (and we verified checksums
            # before and after), so it's now safe to delete the original file.
            File.unlink(original_file_path)
          end

        end

      end

    end

    respond_to do |format|
      format.json {
        render json: {
          'files' => file_data
        }
      }
    end

  end

  def add_parent

    test_mode = params['test'].present? && params['test'].to_s == 'true'

    parent_digital_object = DigitalObject::Base.find(params[:parent_pid])

    if test_mode
      result = true
    else
      @digital_object.add_parent_digital_object(parent_digital_object)
      result = @digital_object.save
    end

    response = {
      'success' => result,
    }

    response['errors'] = @digital_object.errors unless result

    respond_to do |format|
      format.json {
        render json: response
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_digital_object
    @digital_object = DigitalObject::Base.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def digital_object_params
    params.require(:digital_object).permit(
      :dynamic_field_data_json, :project_string_key, :digital_object_type_string_key,
      :parent_digital_object_pids => [], :ordered_child_digital_object_pids => []
    )
    #params.require(:digital_object).permit! # Permit any hash keys under digital_object. This is more open than other controllers because we're receiving dynamic data structures (based on user-defined DynamicFields)
  end

  def set_contextual_nav_options
    @contextual_nav_options['nav_title']['label'] = 'Digital Objects'
  end

  def require_appropriate_project_permissions!

    #case params[:action]
    #when 'index', 'get'
    #  # Do nothing.  Index is open to all logged-in users.
    #when 'new', 'create'
    #  if request.format == 'json'
    #    # For JSON Request the project is set using a string_key
    #    associated_project = Project.where(string_key: params[:digital_object]['project_string_key']).first
    #    require_project_permission!(associated_project, :create)
    #  else
    #    # For JSON Request the project is set using a project_id
    #    unless params[:digital_object].blank?
    #      associated_project = Project.find(params[:digital_object]['project_id'])
    #      require_project_permission!(associated_project, :create)
    #    end
    #  end
    #when 'upload_assets'
    #  require_project_permission!(@digital_object.project, :create)
    #when 'show'
    #  require_project_permission!(@digital_object.project, :read)
    #when 'edit', 'update', 'reorder_child_digital_objects'
    #  require_project_permission!(@digital_object.project, :update)
    #when 'destroy'
    #  require_project_permission!(@digital_object.project, :delete)
    #else
    #  require_hyacinth_admin!
    #end

  end

  # Handles a file upload and returns a hash with information about the upload.
  # Hash format: {'name' => 'file.tif', size => '12345', errors => ['Some error']}
  #
  # param import_type: Valid values
  def handle_single_file_upload(original_filename, original_file_path, import_type, file_to_upload, projects, parent_digital_object)

    file_size = file_to_upload.size
    puts 'File size: ' + file_size.to_s

    upload_response = {
      "name" => original_filename,
      "size" => file_size
    }

    valid_import_types = ['internal', 'external']
    unless valid_import_types.include?(import_type)
      upload_response['errors'] = ['Param import_type must be one of: ' + valid_import_types.join(', ')]
      return upload_response
    end

    original_filename_without_extension = File.basename(original_filename, '.*')

    title_non_sort_portion = ''
    title_sort_portion = original_filename_without_extension
    # Separate non-sort-portion for strings beginning with certain non-sort words (i.e. 'The', 'A', 'An')
    ['The', 'An' 'A'].each{|article|
      if original_filename_without_extension.downcase.slice(article.downcase + ' ').present?
        title_non_sort_portion = article
        title_sort_portion = original_filename_without_extension[article.length + 1, original_filename_without_extension.length]
        break
      end
    }

    new_asset_digital_object = DigitalObject::Asset.new
    new_asset_digital_object.projects = projects
    new_asset_digital_object.add_parent_digital_object(parent_digital_object) if parent_digital_object.present?
    new_asset_digital_object.set_title(title_non_sort_portion, title_sort_portion)

    # Save new_asset_digital_object so that we can get a pid that we'll use to place the uploaded file in the right place
    if new_asset_digital_object.save

      if import_type == 'internal'

        # Generate checksum for original file -- before copy -- using 4096-byte buffered approach to save memory for large files
        original_file_sha256 = Digest::SHA256.new
        while buff = file_to_upload.read(4096)
          original_file_sha256.update(buff)
        end
        original_file_sha256_hexdigest = original_file_sha256.hexdigest
        puts 'Original file hash: ' + original_file_sha256_hexdigest
        file_to_upload.rewind # seek back to start of file for future reading

        # Copy file to final asset destination directory
        path_to_final_save_location = Hyacinth::Utils::PathUtils.path_to_asset_file(new_asset_digital_object.pid, new_asset_digital_object.projects.first, original_filename)

        if File.exists?(path_to_final_save_location)
          raise 'Pre-file-write test unexpectedly found existing file at target location: ' + path_to_final_save_location
        end

        # Recursively make necessary directories
        FileUtils.mkdir_p(File.dirname(path_to_final_save_location))

        # Test write abilities
        FileUtils.touch(path_to_final_save_location)
        unless File.exists?(path_to_final_save_location)
          raise 'Unable to write to file path: ' + path_to_final_save_location
        end

        # Using a write buffer of 4096 bytes so that we don't use too much memory when copying large files.
        # 'w' == write, 'b' == binary mode
        File.open(path_to_final_save_location, 'wb') do |file|
          while buff = file_to_upload.read(4096)
            file.write(buff)
          end
        end

      elsif import_type == 'external'
        path_to_final_save_location = original_file_path
      end

      new_asset_digital_object.set_file_and_file_size_and_original_filename_and_calculate_checksum(path_to_final_save_location, original_filename, file_size)
      new_asset_digital_object.set_original_file_path(original_file_path)
      new_asset_digital_object.set_dc_type_based_on_filename(original_filename)

      # If internal file, confirm that new checksum matches old checksum.  Return error if not.
      if import_type == 'internal'
        original_file_checksum = 'SHA-256:' + original_file_sha256_hexdigest
        final_copy_file_checksum = new_asset_digital_object.get_checksum
        if original_file_checksum != final_copy_file_checksum
          upload_response['errors'] = ["Error during file copy.  Copied file checksum (#{final_copy_file_checksum}) doesn't match original (#{original_file_checksum}).  Delete uploaded record and try again."]
        return upload_response
        end
      end

      new_asset_digital_object.save
    end

    upload_response['errors'] = new_asset_digital_object.errors if new_asset_digital_object.errors.present?

    return upload_response

  end

end
