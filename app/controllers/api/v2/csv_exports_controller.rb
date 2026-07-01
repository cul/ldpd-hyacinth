
# Old controller was called CsvExportsController, maybe we should keep that name for consistency with the model name?
class Api::V2::CsvExportsController < Api::V2::BaseController
  # :show, :edit, :update,
  before_action :set_csv_export, only: [:destroy, :download]

  def index
    authorize! :index, CsvExport
    per_page = 20

    @export_jobs = CsvExport.accessible_by(current_ability)
      .includes(:user)
      .order(id: :desc)
      .page(params[:page])
      .per(per_page)

    render_camelized_json({
      export_jobs: @export_jobs.map { |export_job| export_job_json(export_job) },
      pagination: pagination_data(@export_jobs)
    })
  end

  def destroy
    authorize! :destroy, @csv_export

    @csv_export.destroy
    render_camelized_json({}, status: :no_content)
  end

  def download
    if @csv_export.success?
      send_file @csv_export.path_to_csv_file, filename: File.basename(@csv_export.path_to_csv_file)
    else
      render_camelized_json({
        error: "No download is available for this export job because the job has a status of: #{@csv_export.status}"
      }, status: :unprocessable_entity)
    end
  end

  ######
  # POST /csv_exports
  # NOT USED
  # def create
  #   @csv_export = CsvExport.new(csv_export_params)

  #   respond_to do |format|
  #     if @csv_export.save
  #       format.html { redirect_to @csv_export, notice: 'Csv export was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @csv_export }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @csv_export.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private

    def set_csv_export
      @csv_export = CsvExport.find(params[:id])
    end


    def pagination_data(scope)
      {
        current_page: scope.current_page,
        per_page: scope.limit_value,
        total_pages: scope.total_pages,
        total_count: scope.total_count
      }
    end

    def export_job_json(export_job)
      {
        id: export_job.id,
        status: export_job.status,
        search_params: export_job.search_params,
        path_to_csv_file: export_job.path_to_csv_file,
        number_of_records_processed: export_job.number_of_records_processed,
        duration: export_job.duration,
        created_at: export_job.created_at,
        updated_at: export_job.updated_at,
        user: {
          full_name: export_job.user.full_name,
        }
      }
    end
end
