class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sale, only: [:show, :edit, :update, :destroy]

  def index
    @sales = Sale.includes(:sale_items, :products)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(20)

    # Filtering
    @sales = @sales.where(payment_status: params[:status]) if params[:status].present?
    @sales = @sales.where("project_name ILIKE ? OR client_name ILIKE ? OR description ILIKE ?", 
                          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    
    # Year filtering
    @sales = @sales.where(project_year: params[:year]) if params[:year].present?
  end

  def show
    # @sale is already set by before_action :set_sale with associations loaded
  end

  def new
    @sale = Sale.new
    @sale.sale_date = Date.current
    @sale.sale_items.build
    @products = Product.active.order(:name)
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.sale_date = Date.current if @sale.sale_date.nil?

    if @sale.save
      redirect_to inventory_sales_sale_path(@sale), notice: "Sale was successfully created."
    else
      @products = Product.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.active.order(:name)
  end

  def update
    if @sale.update(sale_params)
      redirect_to inventory_sales_sale_path(@sale), notice: "Sale was successfully updated."
    else
      @products = Product.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sale.destroy
    redirect_to inventory_sales_sales_path, notice: "Sale was successfully deleted."
  end

  private

  def set_sale
    @sale = Sale.includes(:sale_items => :product).find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(
      :client_name, :description, :total_amount, :sale_date, :payment_status, :payment_method, :notes,
      sale_items_attributes: [:id, :product_id, :quantity, :unit_price, :total_price, :_destroy]
    ).tap do |whitelisted|
      # Calculate total_amount from sale_items if not provided
      if whitelisted[:sale_items_attributes].present?
        total = 0
        whitelisted[:sale_items_attributes].each do |key, item_attrs|
          next if item_attrs[:_destroy] == '1'
          quantity = item_attrs[:quantity].to_f
          unit_price = item_attrs[:unit_price].to_f
          total_price = quantity * unit_price
          whitelisted[:sale_items_attributes][key][:total_price] = total_price.to_s
          total += total_price
        end
        whitelisted[:total_amount] = total.to_s unless whitelisted[:total_amount].present?
      end
    end
  end
end

