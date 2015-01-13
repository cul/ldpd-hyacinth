class PidGeneratorsController < ApplicationController
  before_action :require_hyacinth_admin!
  before_action :set_pid_generator, only: [:show, :edit, :update, :destroy]
  before_action :set_contextual_nav_options

  # GET /pid_generators
  # GET /pid_generators.json
  def index
    @pid_generators = PidGenerator.all
  end

  # GET /pid_generators/1
  # GET /pid_generators/1.json
  def show
  end

  # GET /pid_generators/new
  def new
    @pid_generator = PidGenerator.new
  end

  # GET /pid_generators/1/edit
  def edit
  end

  # POST /pid_generators
  # POST /pid_generators.json
  def create
    @pid_generator = PidGenerator.new(pid_generator_params)

    respond_to do |format|
      if @pid_generator.save
        format.html { redirect_to @pid_generator, notice: 'PID Generator was successfully created.' }
        format.json { render action: 'show', status: :created, location: @pid_generator }
      else
        format.html { render action: 'new' }
        format.json { render json: @pid_generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pid_generators/1
  # PATCH/PUT /pid_generators/1.json
  def update
    respond_to do |format|
      if @pid_generator.update(pid_generator_params)
        format.html { redirect_to @pid_generator, notice: 'PID Generator was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @pid_generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pid_generators/1
  # DELETE /pid_generators/1.json
  def destroy

    projects_that_are_using_this_pid_generator = Project.where(pid_generator: @pid_generator)
    if projects_that_are_using_this_pid_generator.length > 0
      flash[:alert] = 'Could not delete selected PID Generator because one or more projects are currently using it (' + projects_that_are_using_this_pid_generator.map{|project|project.string_key}.join(', ') + ').  Select a different PID Generator for these projects and then you will be able to delete this PID Generator.'
    else
      @pid_generator.destroy
    end

    respond_to do |format|
      format.html { redirect_to pid_generators_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_pid_generator
    @pid_generator = PidGenerator.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pid_generator_params
    params.require(:pid_generator).permit(:namespace)
  end

  def set_contextual_nav_options

    @contextual_nav_options['nav_title']['label'] = 'PID Generators'
    @contextual_nav_options['nav_title']['url'] = nil

    case params[:action]
    when 'index'
      @contextual_nav_options['nav_items'].push(label: 'Add New PID Generator', url: new_pid_generator_path)
    when 'edit', 'update'
      @contextual_nav_options['nav_items'].push(label: 'Delete This PID Generator', url: pid_generator_path(@pid_generator.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this PID Generator?' } })

      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to PID Generators'.html_safe
      @contextual_nav_options['nav_title']['url'] = pid_generators_path
    end

  end
end
