class DynamicFieldGroupCategoriesController < ApplicationController
  before_action :set_dynamic_field_group_category, only: [:show, :edit, :update, :destroy]

  # GET /dynamic_field_group_categories
  # GET /dynamic_field_group_categories.json
  def index
    @dynamic_field_group_categories = DynamicFieldGroupCategory.all
  end

  # GET /dynamic_field_group_categories/1
  # GET /dynamic_field_group_categories/1.json
  def show
  end

  # GET /dynamic_field_group_categories/new
  def new
    @dynamic_field_group_category = DynamicFieldGroupCategory.new
  end

  # GET /dynamic_field_group_categories/1/edit
  def edit
  end

  # POST /dynamic_field_group_categories
  # POST /dynamic_field_group_categories.json
  def create
    @dynamic_field_group_category = DynamicFieldGroupCategory.new(dynamic_field_group_category_params)

    respond_to do |format|
      if @dynamic_field_group_category.save
        format.html { redirect_to @dynamic_field_group_category, notice: 'Dynamic field category was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dynamic_field_group_category }
      else
        format.html { render action: 'new' }
        format.json { render json: @dynamic_field_group_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dynamic_field_group_categories/1
  # PATCH/PUT /dynamic_field_group_categories/1.json
  def update
    respond_to do |format|
      if @dynamic_field_group_category.update(dynamic_field_group_category_params)
        format.html { redirect_to @dynamic_field_group_category, notice: 'Dynamic field category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dynamic_field_group_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_field_group_categories/1
  # DELETE /dynamic_field_group_categories/1.json
  def destroy
    @dynamic_field_group_category.destroy
    respond_to do |format|
      format.html { redirect_to dynamic_field_group_categories_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_field_group_category
      @dynamic_field_group_category = DynamicFieldGroupCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_field_group_category_params
      params.require(:dynamic_field_group_category).permit(:display_label, :sort_order)
    end
end
