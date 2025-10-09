class InventorySalesController < ApplicationController
  before_action :authenticate_user!

  def index
    # Main Inventory & Sales dashboard
    @total_products = Product.count
    @total_sales = Sale.sum(:total_amount)
    @total_customers = Customer.count
    @total_orders = Order.count

    # Recent activity
    @recent_sales = Sale.includes(:customer).order(sale_date: :desc).limit(5)
    @low_stock_products = Product.low_stock.limit(5)
    @pending_orders = Order.pending.limit(5)
    @top_selling_products = Product.joins(:sale_items)
                                  .group("products.id")
                                  .order("SUM(sale_items.quantity) DESC")
                                  .limit(3)
  end

  def products
    # Product management
    @products = Product.includes(:order_items, :sale_items)
                      .order(created_at: :desc)
                      .page(params[:page])

    # Filtering
    @products = @products.by_category(params[:category]) if params[:category].present?
    @products = @products.where(status: params[:status]) if params[:status].present?
    @products = @products.where("name ILIKE ? OR sku ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
  end

  def new_product
    @product = Product.new
  end

  def create_product
    @product = Product.new(product_params)

    if @product.save
      redirect_to inventory_sales_products_path, notice: "Product was successfully created."
    else
      render :new_product, status: :unprocessable_entity
    end
  end

  def show_product
    @product = Product.find(params[:id])
  end

  def edit_product
    @product = Product.find(params[:id])
  end

  def update_product
    @product = Product.find(params[:id])

    if @product.update(product_params)
      redirect_to inventory_sales_products_path, notice: "Product was successfully updated."
    else
      render :edit_product, status: :unprocessable_entity
    end
  end

  def destroy_product
    @product = Product.find(params[:id])
    @product.destroy

    redirect_to inventory_sales_products_path, notice: "Product was successfully deleted."
  end

  def sales
    # Sales management
    @sales = Sale.includes(:customer, :sale_items)
                 .order(sale_date: :desc)
                 .page(params[:page])

    # Filtering
    @sales = @sales.where(payment_status: params[:status]) if params[:status].present?
    @sales = @sales.where(payment_method: params[:payment_method]) if params[:payment_method].present?
    @sales = @sales.where("sale_number ILIKE ? OR customers.name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?

    # Date filtering
    case params[:date_range]
    when "today"
      @sales = @sales.today
    when "week"
      @sales = @sales.where(sale_date: 1.week.ago..Time.current)
    when "month"
      @sales = @sales.where(sale_date: 1.month.ago..Time.current)
    end

    # Stats
    @today_sales = Sale.today.sum(:total_amount)
    @week_sales = Sale.where(sale_date: 1.week.ago..Time.current).sum(:total_amount)
    @month_sales = Sale.where(sale_date: 1.month.ago..Time.current).sum(:total_amount)
    @total_transactions = Sale.count
  end

  def customers
    # Customer management
    @customers = Customer.order(created_at: :desc)
                        .page(params[:page])

    # Filtering
    @customers = @customers.by_type(params[:customer_type]) if params[:customer_type].present?
    @customers = @customers.where(status: params[:status]) if params[:status].present?
    @customers = @customers.where("name ILIKE ? OR email ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?

    # Stats
    @total_customers = Customer.count
    @new_this_month = Customer.recent_customers.count
    @active_customers = Customer.active.count
    @avg_order_value = Customer.where(total_orders: 1..).average(:total_spent) || 0
  end

  def new_customer
    @customer = Customer.new
  end

  def create_customer
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to inventory_sales_customers_path, notice: "Customer was successfully created."
    else
      render :new_customer, status: :unprocessable_entity
    end
  end

  def edit_customer
    @customer = Customer.find(params[:id])
  end

  def update_customer
    @customer = Customer.find(params[:id])

    if @customer.update(customer_params)
      redirect_to inventory_sales_customers_path, notice: "Customer was successfully updated."
    else
      render :edit_customer, status: :unprocessable_entity
    end
  end

  def destroy_customer
    @customer = Customer.find(params[:id])
    @customer.destroy

    redirect_to inventory_sales_customers_path, notice: "Customer was successfully deleted."
  end

  def orders
    # Order management
    @orders = Order.includes(:customer, :order_items)
                   .order(order_date: :desc)
                   .page(params[:page])

    # Filtering
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @orders = @orders.where(priority: params[:priority]) if params[:priority].present?
    @orders = @orders.where("order_number ILIKE ? OR customers.name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?

    # Date filtering
    case params[:date_range]
    when "today"
      @orders = @orders.where(order_date: Date.current.all_day)
    when "week"
      @orders = @orders.where(order_date: 1.week.ago..Time.current)
    when "month"
      @orders = @orders.where(order_date: 1.month.ago..Time.current)
    end

    # Stats
    @pending_orders = Order.pending.count
    @processing_orders = Order.processing.count
    @shipped_orders = Order.shipped.count
    @delivered_orders = Order.delivered.count
  end

  def new_order
    @order = Order.new
    @customers = Customer.active.order(:name)
    @products = Product.active.order(:name)
  end

  def create_order
    @order = Order.new(order_params)
    @customers = Customer.active.order(:name)
    @products = Product.active.order(:name)

    if @order.save
      redirect_to inventory_sales_order_path(@order), notice: "Order was successfully created."
    else
      render :new_order, status: :unprocessable_entity
    end
  end

  def show_order
    @order = Order.includes(:customer, order_items: :product).find(params[:id])
  end

  def edit_order
    @order = Order.find(params[:id])
    @customers = Customer.active.order(:name)
    @products = Product.active.order(:name)
  end

  def update_order
    @order = Order.find(params[:id])
    @customers = Customer.active.order(:name)
    @products = Product.active.order(:name)

    if @order.update(order_params)
      redirect_to inventory_sales_order_path(@order), notice: "Order was successfully updated."
    else
      render :edit_order, status: :unprocessable_entity
    end
  end

  def destroy_order
    @order = Order.find(params[:id])
    @order.destroy

    redirect_to inventory_sales_orders_path, notice: "Order was successfully deleted."
  end

  def reports
    # Sales and inventory reports
    @date_range = params[:date_range] || "month"

    # Set date range
    case @date_range
    when "week"
      @start_date = 1.week.ago
      @end_date = Time.current
    when "month"
      @start_date = 1.month.ago
      @end_date = Time.current
    when "quarter"
      @start_date = 3.months.ago
      @end_date = Time.current
    when "year"
      @start_date = 1.year.ago
      @end_date = Time.current
    else
      @start_date = 1.month.ago
      @end_date = Time.current
    end

    # Key metrics
    @total_revenue = Sale.where(sale_date: @start_date..@end_date).sum(:total_amount)
    @total_units_sold = SaleItem.joins(:sale).where(sales: { sale_date: @start_date..@end_date }).sum(:quantity)
    @avg_order_value = Sale.where(sale_date: @start_date..@end_date).average(:total_amount) || 0
    @conversion_rate = SystemSetting.get_float("default_conversion_rate", 3.2)

    # Sales by category
    @sales_by_category = Product.joins(:sale_items)
                               .joins("JOIN sales ON sale_items.sale_id = sales.id")
                               .where(sales: { sale_date: @start_date..@end_date })
                               .group(:category)
                               .sum("sale_items.total_price")

    # Customer demographics
    @customer_demographics = Customer.group(:customer_type).count

    # Recent reports
    @recent_reports = Report.recent.limit(3)
  end

  private

  def product_params
    params.require(:product).permit(:name, :sku, :description, :category, :price, :stock_quantity, :reorder_level, :status)
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :address, :customer_type, :status, :notes)
  end

  def order_params
    params.require(:order).permit(:customer_id, :order_date, :status, :priority, :notes, order_items_attributes: [ :id, :product_id, :quantity, :unit_price, :_destroy ])
  end
end
