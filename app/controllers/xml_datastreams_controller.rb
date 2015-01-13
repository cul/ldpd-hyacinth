class XmlDatastreamsController < ApplicationController
  before_action :set_xml_datastream, only: [:show, :edit, :update, :destroy]

  # GET /xml_datastreams
  # GET /xml_datastreams.json
  def index
    @xml_datastreams = XmlDatastream.all
  end

  # GET /xml_datastreams/1
  # GET /xml_datastreams/1.json
  def show
  end

  # GET /xml_datastreams/new
  def new
    @xml_datastream = XmlDatastream.new
  end

  # GET /xml_datastreams/1/edit
  def edit
  end

  # POST /xml_datastreams
  # POST /xml_datastreams.json
  def create
    @xml_datastream = XmlDatastream.new(xml_datastream_params)

    respond_to do |format|
      if @xml_datastream.save
        format.html { redirect_to @xml_datastream, notice: 'Xml datastream was successfully created.' }
        format.json { render action: 'show', status: :created, location: @xml_datastream }
      else
        format.html { render action: 'new' }
        format.json { render json: @xml_datastream.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /xml_datastreams/1
  # PATCH/PUT /xml_datastreams/1.json
  def update
    respond_to do |format|
      if @xml_datastream.update(xml_datastream_params)
        format.html { redirect_to @xml_datastream, notice: 'Xml datastream was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @xml_datastream.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /xml_datastreams/1
  # DELETE /xml_datastreams/1.json
  def destroy
    @xml_datastream.destroy
    respond_to do |format|
      format.html { redirect_to xml_datastreams_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_xml_datastream
      @xml_datastream = XmlDatastream.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def xml_datastream_params
      params.require(:xml_datastream).permit(:string_key, :display_label, :xml_translation_json)
    end
end
