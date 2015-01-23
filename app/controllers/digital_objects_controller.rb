# encoding: utf-8

class DigitalObjectsController < ApplicationController
  before_action :set_digital_object, only: [:show, :edit, :update, :destroy, :data_for_ordered_child_editor, :upload_assets]
  before_action :set_contextual_nav_options

  # GET /digital_objects
  # GET /digital_objects.json
  def index
  end

  def search
    respond_to do |format|
      format.json {
        render json: DigitalObject::Base.search(params['search'].present? ? params['search'] : {}, params['facet'].present? ? params['facet'] : {})
      }
    end
  end

  # GET /digital_objects/cul:123.json
  def show
    respond_to do |format|
      format.json {
        render json: @digital_object
      }
      format.xml {
        #if params[:xml_type].blank? || params[:xml_type] == 'mods'
        #  render xml: @digital_object.as_mods_xml
        #else
        #  render xml: '<?xml version="1.0" encoding="UTF-8"?><error>Unknown XML export format: ' + params[:xml_type] + '</error>'
        #end
        render xml: '<?xml version="1.0" encoding="UTF-8"?><error>XML view is not available.</error>'

      }
    end
  end

  # POST /digital_objects
  # POST /digital_objects.json
  def create

    test_mode = params['test'].present? && params['test'] == 'true'

    project = Project.find_by(string_key: digital_object_params['project_string_key'])
    digital_object_type = DigitalObjectType.find_by(string_key: digital_object_params['digital_object_type_string_key'])

    class_to_instantiate = digital_object_type.get_associated_model
    @digital_object = class_to_instantiate.new
    @digital_object.created_by = current_user
    @digital_object.updated_by = current_user
    @digital_object.projects << project

    unless digital_object_params['dynamic_field_data_json'].nil?
      dynamic_field_data_json = Hyacinth::Utils::StringUtils.clean_utf8_string(digital_object_params['dynamic_field_data_json'])
      #dynamic_field_data_json = digital_object_params['dynamic_field_data_json']
      raise 'Invalid JSON given for dynamic_field_data_json' unless Hyacinth::Utils::JsonUtils.is_valid_json?(dynamic_field_data_json)
      @digital_object.update_dynamic_field_data(JSON(dynamic_field_data_json))
    end

    if digital_object_params['parent_digital_object_pids']
      @digital_object.parent_digital_object_pids = digital_object_params['parent_digital_object_pids']
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

    if digital_object_params['state']
      @digital_object.state = digital_object_params['state']
    end

    if digital_object_params['ordered_child_digital_object_pids']
      @digital_object.ordered_child_digital_object_pids = digital_object_params['ordered_child_digital_object_pids']
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
            errors: 'An unexpected error occurred during deletion.'
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

    ordered_child_digital_objects = @digital_object.ordered_child_digital_object_pids.blank? ? [] : @digital_object.ordered_child_digital_object_pids.map{|pid|DigitalObject::Base.find(pid)}

    respond_to do |format|
      format.json {
        render json: {
          digital_object: @digital_object,
          ordered_child_digital_objects: ordered_child_digital_objects
        }
      }
    end

  end

  def upload_assets

    overall_errors = []

    # Only DigitalObject::Item objects can have child assets
    unless @digital_object.is_a?(DigitalObject::Item)
      overall_errors << "You can only upload assets to a parent Digital Object of type Item.  Object with pid #{@digital_object.pid} is of type: #{@digital_object.digital_object_type.display_label}"
    end

    file_data = []

    # Case 1: We're receiving file data from an HTTP upload
    if params['files'].present?

      # Immediately unlink all files.  This is recommended for POSIX systems,
      # but the code below should still work on non-POSIX systems (like Windows).
      # Why do we do this?  Cleans up temp files as quickly as possible so they
      # don't wait around to be garbage collected.  With lots of file uploads,
      # accumulation of too many temp files could be problematic.
      # Recommended here: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tempfile/rdoc/Tempfile.html (See: "Unlink after creation")
      # And here: http://docs.ruby-lang.org/en/2.1.0/Tempfile.html (See: "Unlink-before-close")

      params['files'].each {|uploaded_file|
        uploaded_file.tempfile.unlink # On Windows, this silently fails.  We still need to use a begin/ensure clause with file.tempfile.close.
      }

      params['files'].each {|uploaded_file|
        begin

          # If we don't utf-8 clean the original filename and original file path and there are weird characters (like "\xC2"), Ruby will die a horrible death.  Let's keep Ruby alive.
          original_filename = Hyacinth::Utils::StringUtils.clean_utf8_string(uploaded_file.original_filename).strip
          original_filename_without_extension = File.basename(original_filename)
          original_file_path = '' # For now, always blank for HTTP file uploads

          file_data_for_json_response = {
            "name" => original_filename,
            "size" => uploaded_file.tempfile.length,
          }

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
          new_asset_digital_object.projects = @digital_object.projects
          new_asset_digital_object.parent_digital_object_pids << @digital_object.pid
          new_asset_digital_object.add_title(title_non_sort_portion, title_sort_portion)

          # Save new_asset_digital_object so that we can get a pid that we'll use to place the uploaded file in the right place
          if new_asset_digital_object.save
            path_to_file_in_hyacinth_asset_directory = Hyacinth::Utils::PathUtils.path_to_asset_file(new_asset_digital_object.pid, original_filename)

            if File.exists?(path_to_file_in_hyacinth_asset_directory)
              raise 'Pre-file-write test unexpectedly found existing file at target location: ' + path_to_file_in_hyacinth_asset_directory
            end

            # Recursively make necessary directories
            FileUtils.mkdir_p(File.dirname(path_to_file_in_hyacinth_asset_directory))

            # Test write abilities
            FileUtils.touch(path_to_file_in_hyacinth_asset_directory)
            unless File.exists?(path_to_file_in_hyacinth_asset_directory)
              raise 'Unable to write to file path: ' + path_to_file_in_hyacinth_asset_directory
            end

            # Copy file to final asset destination directory
            # Using a write buffer of 4096 bytes so that we don't use too much memory when copying large files.
            # 'w' == write, 'b' == binary mode
            File.open(path_to_file_in_hyacinth_asset_directory, 'wb') do |file|
              while buff = uploaded_file.tempfile.read(4096)
                file.write(buff)
              end
            end

            new_asset_digital_object.set_file_and_original_filename_and_calculate_checksum(path_to_file_in_hyacinth_asset_directory, original_filename)
            new_asset_digital_object.set_original_file_path(original_file_path)
            new_asset_digital_object.set_dc_type_based_on_filename(original_filename)

            new_asset_digital_object.save
          end

          file_data_for_json_response['errors'] = new_asset_digital_object.errors if new_asset_digital_object.errors.present?

          file_data << file_data_for_json_response

        ensure
           uploaded_file.tempfile.close!  # Closes the file handle. If the file wasn't unlinked earlier
                                # because #unlink failed, then this method will attempt
                                # to do so again.
        end
      }

    elsif params['filesystem_file_locations']
      # Case 2: We're receiving file data from a list of filesystem locations.
      # TODO: This isn't currently supported, but will be at some point.

    end

    respond_to do |format|
      format.json {
        render json: {
          'files' => file_data
        }
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
      :dynamic_field_data_json, :state, :project_string_key, :digital_object_type_string_key,
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

end
