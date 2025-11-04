class MaterialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_material, only: [:show, :edit, :update, :destroy]

  def index
    @materials = Material.includes(:vendor).by_name.page(params[:page]).per(20)
    
    # Filter by status if provided
    @materials = @materials.where(status: params[:status]) if params[:status].present?
    
    # Search by name or description if provided
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @materials = @materials.where("name ILIKE ? OR description ILIKE ?", search_term, search_term)
    end
  end

  def show
  end

  def new
    @material = Material.new
    @vendors = Vendor.active.by_name
  end

  def create
    @material = Material.new(material_params)

    if @material.save
      redirect_to inventory_sales_material_path(@material), notice: "Material was successfully created."
    else
      @vendors = Vendor.active.by_name
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vendors = Vendor.active.by_name
  end

  def update
    if @material.update(material_params)
      redirect_to inventory_sales_material_path(@material), notice: "Material was successfully updated."
    else
      @vendors = Vendor.active.by_name
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @material.destroy
    redirect_to inventory_sales_materials_path, notice: "Material was successfully deleted."
  end

  private

  def set_material
    @material = Material.find(params[:id])
  end

  def material_params
    params.require(:material).permit(:name, :description, :unit, :unit_price, :status, :vendor_id)
  end
end

