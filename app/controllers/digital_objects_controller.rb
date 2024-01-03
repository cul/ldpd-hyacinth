# encoding: utf-8

class DigitalObjectsController < ApplicationController
  include Hyacinth::DigitalObjects::EditorBehavior
  include Hyacinth::DigitalObjects::ParentEditorBehavior
  include Hyacinth::DigitalObjects::UploadsEditorBehavior
  include Hyacinth::DigitalObjects::Downloads
  include Hyacinth::DigitalObjects::Transcript
  include Hyacinth::DigitalObjects::IndexDocument
  include Hyacinth::DigitalObjects::Captions

  DIRECT_UPLOAD_FILE_PARAM_NAMES = [:file, :access_copy_file, :poster_file]

  before_action :set_digital_object, only: [:show, :edit, :update, :destroy, :undestroy, :data_for_ordered_child_editor,
    :download, :download_access_copy, :download_poster, :download_service_copy,
    :add_parent, :remove_parents, :mods, :xacml, :media_view, :rotate_image, :regenerate_access_copy, :swap_order_of_first_two_child_assets,
    :download_transcript, :update_transcript,
    :download_index_document, :update_index_document,
    :download_captions, :update_captions,
    :download_synchronized_transcript, :update_synchronized_transcript, :clear_synchronized_transcript_and_reimport_transcript,
    :update_featured_region, :query_featured_region
  ]
  before_action :set_digital_object_for_data_for_editor_action, only: [:data_for_editor]
  before_action :set_contextual_nav_options
  before_action :set_var_digital_object_data_or_render_error, only: [:create, :update]
  before_action :require_appropriate_project_permissions!

  # GET /digital_objects
  # GET /digital_objects.json
  def index
  end

  def set_var_digital_object_data_or_render_error
    @digital_object_data = params[:digital_object_data_json].blank? ? {} : convert_digital_object_data_json(params[:digital_object_data_json])
    true
  end

  def posted_file_data(import_type)
    return @digital_object_data['import_file'] unless import_type == DigitalObject::Asset::IMPORT_TYPE_POST_DATA
    upload = params[:file]

    {
      'import_type' => DigitalObject::Asset::IMPORT_TYPE_POST_DATA,
      'import_path' => upload.tempfile.path,
      'original_file_path' => upload.original_filename
    }
  end

  # Intialize @digital_object
  # Returns: an array of error messages, or nil if successful
  def initialize_digital_object
    return ['Missing digital_object_data_json[digital_object_type]'] if @digital_object_data['digital_object_type'].blank?

    begin
      @digital_object = DigitalObjectType.get_model_for_string_key(@digital_object_data['digital_object_type']['string_key']).new
    rescue Hyacinth::Exceptions::InvalidDigitalObjectTypeError
      return ["Invalid digital_object_type specified: digital_object_type => #{@digital_object_data['digital_object_type'].inspect}"]
    end
    nil
  end

  def save_or_validate_digital_object
    return @digital_object.valid? if params['test'].to_s == 'true'
    @digital_object.save
  end

  # POST /digital_objects
  # POST /digital_objects.json
  def create
    initialization_errors = initialize_digital_object
    if initialization_errors.present?
      render json: { success: false, errors: initialization_errors }
      return
    end
    handle_direct_file_uploads!(@digital_object_data)
    if @digital_object.is_a?(DigitalObject::Asset)
      master_file_import_errors = validate_master_file_import_params(@digital_object_data, current_user.admin?)
      if master_file_import_errors.present?
        render json: { success: false, errors: master_file_import_errors }
        return
      end
    end
    @digital_object.set_digital_object_data(@digital_object_data, false)

    @digital_object.created_by = current_user
    @digital_object.updated_by = current_user

    test_mode = params['test'].to_s == 'true'

    handle_publish_param(@digital_object, params)
    handle_mint_reserved_doi_param(@digital_object, params)

    if save_or_validate_digital_object
      render_json = { success: true }.merge!(@digital_object.as_confirmation_json)
      render_json['test'] = true if test_mode
    else
      render_json = { errors: @digital_object.errors }
    end

    render json: render_json
  rescue Hyacinth::Exceptions::NotFoundError, Hyacinth::Exceptions::MalformedControlledTermFieldValue => e
    render json: { success: false, errors: [e.message] }
  ensure
    close_and_unlink_direct_file_uploads
  end

  def validate_master_file_import_params(digital_object_data, is_admin)
    data_errors = []
    if digital_object_data['import_file'].blank?
      data_errors << 'Missing digital_object_data_json[import_file] for new Asset'
      return data_errors
    end
    import_type = digital_object_data['import_file']['import_type']
    import_file = digital_object_data['import_file']['import_file']
    if import_type == DigitalObject::Asset::IMPORT_TYPE_POST_DATA && !import_file
      data_errors << "An attached file is required in the request data for imports of type: #{import_type}"
    end
    if import_type == DigitalObject::Asset::IMPORT_TYPE_EXTERNAL && !is_admin
      data_errors << "Only admins can perform external file imports."
    end
  end

  # DELETE /digital_objects/1
  # DELETE /digital_objects/1.json
  def destroy
    render_json = @digital_object.destroy ? { success: true } : { errors: @digital_object.errors }
    respond_to do |format|
      format.json { render json: render_json }
    end
  end

  # PATCH/PUT /digital_objects/1
  # PATCH/PUT /digital_objects/1.json
  def update
    # Default behavior is to merge dynamic fields by default, unless told not to.
    merge_dynamic_fields = params['merge_dynamic_fields'].to_s != 'false'
    begin
      handle_direct_file_uploads!(@digital_object_data) if @digital_object.is_a?(DigitalObject::Asset)
      @digital_object.set_digital_object_data(@digital_object_data, merge_dynamic_fields)
    rescue Hyacinth::Exceptions::NotFoundError, Hyacinth::Exceptions::MalformedControlledTermFieldValue => e
      render json: { success: false, errors: [e.message] }
      return
    end

    @digital_object.updated_by = current_user

    test_mode = params['test'].to_s == 'true'

    handle_publish_param(@digital_object, params)
    handle_mint_reserved_doi_param(@digital_object, params)

    # Whenever a direct file upload occurs, that triggers a republish so that DLC
    # can reindex the object with the access/poster info.
    republish_after_save = @digital_object.is_a?(DigitalObject::Asset) && request_includes_direct_upload_file_param?

    if test_mode ? @digital_object.valid? : @digital_object.save
      render_json = { success: true, pid: @digital_object.pid }.merge(test_mode ? { 'test' => true } : {})
      RepublishAssetJob.perform_later(@digital_object.pid) if republish_after_save
    else
      render_json = { errors: @digital_object.errors }
    end
    respond_to do |format|
      format.json { render json: render_json }
    end
  ensure
    close_and_unlink_direct_file_uploads
  end

  # PUT /digital_objects/1/undelete.json
  def undestroy
    @digital_object.state = 'A'
    render_json = @digital_object.save ? { success: true } : { errors: @digital_object.errors }
    respond_to do |format|
      format.json { render json: render_json }
    end
  end

  def data_for_editor
    respond_to do |format|
      format.json { render json: object_data_for_editor(@digital_object) }
    end
  end

  def search_results_to_csv
    # these params are stringified unless they are permitted
    permitted = params.permit('search' => {})
    search_param = permitted.to_h['search']
    csv_export = CsvExport.create(user: current_user, search_params: JSON.generate(search_param))

    Hyacinth::Queue.export_search_results_to_csv(csv_export.id)

    respond_to do |format|
      format.json { render json: { success: true, csv_export_id: csv_export.id } }
    end
  end

  def search
    # these params are stringified unless they are permitted
    permitted = params.permit('search' => {}, 'facet' => {})
    search_param = permitted.to_h['search']
    facet_param = permitted.to_h['facet']
    respond_to do |format|
      format.json do
        search_response = DigitalObject::Base.search(
          search_param.present? ? search_param : {},
          current_user,
          facet_param.present? ? facet_param : {}
        )
        if params['include_single_field_searchable_field_list'] && params['include_single_field_searchable_field_list'].to_s == 'true'
          search_response['single_field_searchable_fields'] = Hash[DynamicField.where(is_single_field_searchable: true).order([:standalone_field_label, :string_key]).map { |dynamic_field| [dynamic_field.string_key, dynamic_field.standalone_field_label] }]
        end
        render json: search_response
      end
    end
  end

  def titles_for_pids
    respond_to do |format|
      format.json { render json: DigitalObject::Base.titles_for_pids(params[:pids].blank? ? [] : params[:pids], current_user) }
    end
  end

  # GET /digital_objects/cul:123.json
  def show
    respond_to do |format|
      format.json { render json: @digital_object }
    end
  end

  def mods
    xml_output = @digital_object.render_xml_datastream(XmlDatastream.find_by(string_key: 'descMetadata'))

    respond_to do |format|
      format.xml { render plain: xml_output, content_type: 'text/xml' }
    end
  end

  def xacml
    xml_output = @digital_object.render_xml_datastream(XmlDatastream.find_by(string_key: 'accessControlMetadata'))

    respond_to do |format|
      format.xml { render plain: xml_output, content_type: 'text/xml' }
    end
  end

  # A view for image zooming, video players, audio players, etc.
  def media_view
    raise 'This view is only available for assets.' unless @digital_object.is_a?(DigitalObject::Asset)
    render layout: 'content_only'
  end

  def data_for_ordered_child_editor
    respond_to do |format|
      format.json do
        render json: ordered_children_data_for_editor(@digital_object)
      end
    end
  end

  def saveable?(errors = nil)
    errors.blank? && (params['test'].blank? || params['test'].to_s != 'true')
  end

  def rotate_image
    unless @digital_object.is_a?(DigitalObject::Asset) && @digital_object.dc_type == 'StillImage'
      render json: { errors: ["Only Assets of type StillImage can be rotated.  This is a #{@digital_object.digital_object_type.display_label} of type #{@digital_object.dc_type}"] }
      return
    end

    rotate_by = params[:rotate_by].to_i
    @digital_object.fedora_object.orientation += rotate_by
    # TODO: Maybe later, preserve and rotate previous region if image is rotated.
    # For now, don't worry about it and just CLEAR the previous region.  Users almost never select a
    # region BEFORE rotating an image.
    @digital_object.featured_region = nil
    # @digital_object.featured_region = @digital_object.rotated_region(rotate_by) if @digital_object.featured_region.present?

    if @digital_object.save && @digital_object.regenerate_derivatives!(access_copy: true, image_server_cache: true)
      render json: { success: true }
    else
      render json: { errors: ['An error occurred during image regeneration.'] }
    end
  end

  def regenerate_access_copy
    unless @digital_object.is_a?(DigitalObject::Asset)
      render json: { errors: ["Only Assets have access copies.  This is a #{@digital_object.digital_object_type.display_label}."] }
      return
    end

    if @digital_object.regenerate_derivatives!(access_copy: true, image_server_cache: true)
      render json: { success: true }
    else
      render json: { errors: ['An error occurred during access copy regeneration.'] }
    end
  end

  def update_featured_region
    unless @digital_object.is_a?(DigitalObject::Asset)
      render json: { errors: ["Only Assets can have featured regions.  This is a #{@digital_object.digital_object_type.display_label} of type #{@digital_object.dc_type}"] }
      return
    end
    unless params[:region].to_s =~ /(\d+,){3}\d+/
      render json: { errors: ["Featured regions must be a valid IIIF region.  Given #{params[:region]}"] }
      return
    end

    @digital_object.featured_region = params[:region]
    @digital_object.region_selection_event = { 'updatedBy' => current_user.email }
    if @digital_object.save && @digital_object.regenerate_derivatives!(access_copy: false, image_server_cache: true)
      render json: { success: true }.merge(@digital_object.region_selection_event)
    else
      errors = @digital_object.errors[:featured_region]
      errors = ['An error occurred during image regeneration.'] if errors.blank?
      render json: { errors: errors }
    end
  end

  def query_featured_region
    unless @digital_object.is_a?(DigitalObject::Asset)
      render json: { errors: ["Only Assets can have featured regions.  This is a #{@digital_object.digital_object_type.display_label} of type #{@digital_object.dc_type}"] }
      return
    end
    render json: { success: true }.merge(@digital_object.region_selection_event).merge('region' => @digital_object.featured_region)
  end

  def swap_order_of_first_two_child_assets
    if @digital_object.is_a?(DigitalObject::Item) && @digital_object.ordered_child_digital_object_pids.length == 2
      @digital_object.ordered_child_digital_object_pids = @digital_object.ordered_child_digital_object_pids.reverse
      if @digital_object.save
        render json: { success: true, ordered_child_digital_object_pids: @digital_object.ordered_child_digital_object_pids }
      else
        render json: { errors: ['An error occurred during image regeneration.'] }
      end
    else
      render json: { errors: ["Only Items with 2 child assets can have have their first two assets swapped.  This is a #{@digital_object.digital_object_type.display_label} with #{@digital_object.ordered_child_digital_object_pids.length} child assets."] }
    end
  end

  # def upload_access_copy
  #   if @digital_object.is_a?(DigitalObject::Asset)
  #     if params[:file].blank?
  #       render status: :bad_request, json: { errors: ['Missing multipart/form-data file upload data with name: file'] }
  #       return
  #     end

  #     @digital_object_data = {}
  #     @digital_object_data['import_file'] = posted_file_data(DigitalObject::Asset::IMPORT_TYPE_POST_DATA)
  #     @digital_object.set_digital_object_data({
  #       'import_file' => {
  #         'access_copy_import_path' => params[:file].tempfile.path
  #       }
  #     }, true)
  #     @digital_object.updated_by = current_user

  #     if @digital_object.save
  #       RepublishAssetJob.perform_later(@digital_object.pid)
  #       render json: { success: true, size: @digital_object.access_copy_file_size_in_bytes.to_i }
  #     else
  #       render json: { errors: ['An error occurred during access copy upload.'] }
  #     end
  #   else
  #     render json: { errors: ["This action is only allowed for Assets.  This object has type: #{@digital_object.digital_object_type.display_label}"] }
  #   end
  # ensure
  #   close_and_unlink_direct_file_uploads
  # end

  # def upload_poster
  #   if @digital_object.is_a?(DigitalObject::Asset)
  #     if params[:file].blank?
  #       render status: :bad_request, json: { errors: ['Missing multipart/form-data file upload data with name: file'] }
  #       return
  #     end

  #     @digital_object_data = {}
  #     @digital_object_data['import_file'] = posted_file_data(DigitalObject::Asset::IMPORT_TYPE_POST_DATA)
  #     @digital_object.set_digital_object_data({
  #       'import_file' => {
  #         'poster_import_path' => params[:file].tempfile.path
  #       }
  #     }, true)
  #     @digital_object.updated_by = current_user

  #     if @digital_object.save
  #       RepublishAssetJob.perform_later(@digital_object.pid)
  #       render json: { success: true, size: @digital_object.poster_file_size_in_bytes.to_i }
  #     else
  #       render json: { errors: ['An error occurred during poster upload.'] }
  #     end
  #   else
  #     render json: { errors: ["This action is only allowed for Assets.  This object has type: #{@digital_object.digital_object_type.display_label}"] }
  #   end
  # ensure
  #   close_and_unlink_direct_file_uploads
  # end

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

    def publish_requirements_from_params
      params[:publish].to_s == 'true' ? [:publish] : []
    end

    def require_appropriate_project_permissions!
      publish_requirements = publish_requirements_from_params
      case params[:action]
      when 'index', 'search', 'upload_directory_listing', 'titles_for_pids', 'search_results_to_csv'
        # Do nothing.  These actions are open to all logged-in users.
      when 'show', 'data_for_editor', 'mods', 'download', 'data_for_ordered_child_editor', 'media_view', 'download_transcript', 'download_index_document', 'download_captions', 'download_synchronized_transcript', 'download_access_copy', 'download_poster', 'download_service_copy', 'download'
        require_project_permission!(@digital_object.project, :read)
      when 'create'
        # Access logic inside action method
        project_find_criteria = @digital_object_data['project'] # i.e. {string_key: 'proj'} or {pid: 'abc:123'}
        associated_project = Project.find_by(project_find_criteria)
        publish_requirements << :create
        require_project_permission!(associated_project, publish_requirements)
      when 'update', 'reorder_child_digital_objects', 'add_parent', 'remove_parents', 'rotate_image', 'regenerate_access_copy', 'swap_order_of_first_two_child_assets', 'update_transcript', 'update_index_document', 'update_captions', 'update_synchronized_transcript', 'clear_synchronized_transcript_and_reimport_transcript',
        require_project_permission!(@digital_object.project, :update)
        # Also require publish permission if params[:publish] is set to true (note: applies to the 'update' action)
        publish_requirements << :update
        require_project_permission!(@digital_object.project, publish_requirements)
      when 'destroy', 'undestroy'
        require_project_permission!(@digital_object.project, :delete)
      else
        require_hyacinth_admin!
      end
    end

    def convert_digital_object_data_json(digital_object_data_json)
      # Convert json-encoded digital_object_data_json to hash
      # Note: We submit digital_object_data to the API as JSON to preserve array order, since http param order isn't guaranteed
      return if digital_object_data_json.nil?
      raise 'Invalid JSON given for digital_object_data_json' unless Hyacinth::Utils::JsonUtils.valid_json?(digital_object_data_json)
      JSON.parse(digital_object_data_json)
    end

    def handle_publish_param(digital_object, prms)
      digital_object.publish_after_save = (prms['publish'].to_s == 'true') if prms.key?('publish')
    end

    def handle_mint_reserved_doi_param(digital_object, prms)
      digital_object.mint_reserved_doi_before_save = (prms['mint_reserved_doi'].to_s == 'true') if prms.key?('mint_reserved_doi')
    end

    def request_includes_direct_upload_file_param?
      DIRECT_UPLOAD_FILE_PARAM_NAMES.find { |param_name| params[param_name].present? }
    end

    # Modifies the given digital_object_data object, setting it up for file uploads if the
    # appropriate file data is in the request params.
    def handle_direct_file_uploads!(digital_object_data)
      return unless request_includes_direct_upload_file_param?

      digital_object_data['import_file'] ||= {}
      import_file_data = digital_object_data['import_file']
      DIRECT_UPLOAD_FILE_PARAM_NAMES.each do |file_param_name|
        next unless params[file_param_name].present?

        upload = params[file_param_name]
        if file_param_name == :file
          import_file_data['import_path'] = upload.tempfile.path
          import_file_data['import_type'] = DigitalObject::Asset::IMPORT_TYPE_POST_DATA
          import_file_data['original_file_path'] = upload.original_filename
        else
          import_file_data["#{file_param_name.to_s.gsub(/_file$/, '')}_import_path"] = params[file_param_name].tempfile.path
        end
      end
    end

    def close_and_unlink_direct_file_uploads
      # If we're dealing with any file uploads (which isn't always the case), make sure to close the
      # files when we're done.
      # Immediately unlink the uploaded files.  This is recommended for POSIX systems,
      # but the code below should still work on non-POSIX systems (like Windows).
      # Why do we do this?  Cleans up temp files as quickly as possible so they
      # don't wait around to be garbage collected.  With lots of file uploads,
      # accumulation of too many temp files could be problematic.
      # Recommended here: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tempfile/rdoc/Tempfile.html (See: "Unlink after creation")
      # And here: http://docs.ruby-lang.org/en/2.1.0/Tempfile.html (See: "Unlink-before-close")
      DIRECT_UPLOAD_FILE_PARAM_NAMES.each do |file_param_name|
        if params[file_param_name].present?
          params[file_param_name].tempfile.close
          params[file_param_name].tempfile.unlink
        end
      end
    end
end
