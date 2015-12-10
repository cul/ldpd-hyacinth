class CsvExportsController < ApplicationController
  before_action :set_csv_export, only: [:show, :edit, :update, :destroy]
  before_action :set_contextual_nav_options

  # GET /csv_exports
  # GET /csv_exports.json
  def index
    @csv_exports = CsvExport.all
  end

  # GET /csv_exports/1
  # GET /csv_exports/1.json
  def show
  end

  # GET /csv_exports/new
  def new
    @csv_export = CsvExport.new
  end

  # GET /csv_exports/1/edit
  def edit
  end

  # POST /csv_exports
  # POST /csv_exports.json
  def create
    @csv_export = CsvExport.new(csv_export_params)

    respond_to do |format|
      if @csv_export.save
        format.html { redirect_to @csv_export, notice: 'Csv export was successfully created.' }
        format.json { render action: 'show', status: :created, location: @csv_export }
      else
        format.html { render action: 'new' }
        format.json { render json: @csv_export.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /csv_exports/1
  # PATCH/PUT /csv_exports/1.json
  def update
    respond_to do |format|
      if @csv_export.update(csv_export_params)
        format.html { redirect_to @csv_export, notice: 'Csv export was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @csv_export.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /csv_exports/1
  # DELETE /csv_exports/1.json
  def destroy
    @csv_export.destroy
    respond_to do |format|
      format.html { redirect_to csv_exports_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_csv_export
    @csv_export = CsvExport.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def csv_export_params
    params.require(:csv_export).permit(:search_params, :user_id, :path_to_csv_file, :status)
  end
  
  def set_contextual_nav_options

    @contextual_nav_options['nav_title']['label'] = 'CSV Exports'
    @contextual_nav_options['nav_title']['url'] = csv_exports_path

  end
  
end
