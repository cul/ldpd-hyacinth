class Api::V2::XmlDatastreamsController < Api::V2::BaseController
  before_action :set_xml_datastream_by_string_key, only: [:show, :update]

  # All actions below should be available to Hyacinth admins only

  # GET /api/v2/xml_datastreams
  def index
    authorize! :index, XmlDatastream
    @xml_datastreams = XmlDatastream.all
    render_camelized_json({ xml_datastreams: @xml_datastreams.map { |xml_datastream| xml_datastream_json(xml_datastream) } })
  end

  # GET /api/v2/xml_datastreams/:string_key
  def show
    authorize! :show, @xml_datastream
    render_camelized_json({ xml_datastream: xml_datastream_json(@xml_datastream) })
  end

  # PATCH/PUT /api/v2/xml_datastreams/:string_key
  def update
    authorize! :update, @xml_datastream

    # TODO: Implement update logic
  end

  def create
    authorize! :create, XmlDatastream

    # TODO: Implement create logic
  end


  private

    def xml_datastream_json(xml_datastream)
      {
        id: xml_datastream.id,
        string_key: xml_datastream.string_key,
        display_label: xml_datastream.display_label,
        xml_translation: xml_datastream.xml_translation
      }
    end

    def xml_datastream_params
      #  TODO
    end


    def set_xml_datastream_by_string_key
      @xml_datastream = XmlDatastream.find_by!(string_key: params[:string_key])
    end
end
