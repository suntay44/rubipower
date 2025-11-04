class VendorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vendor, only: [:show, :edit, :update, :destroy]

  def index
    @vendors = Vendor.by_name.page(params[:page]).per(20)
    
    # Filter by status if provided
    @vendors = @vendors.where(status: params[:status]) if params[:status].present?
    
    # Search by name or TIN if provided
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @vendors = @vendors.where("name ILIKE ? OR tin ILIKE ?", search_term, search_term)
    end
  end

  def show
  end

  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new(vendor_params)

    if @vendor.save
      # Handle file attachments
      @vendor.tax_certificate.attach(params[:vendor][:tax_certificate]) if params[:vendor][:tax_certificate].present?
      @vendor.sales_invoice.attach(params[:vendor][:sales_invoice]) if params[:vendor][:sales_invoice].present?
      @vendor.vendor_quotation.attach(params[:vendor][:vendor_quotation]) if params[:vendor][:vendor_quotation].present?
      @vendor.sample_sales_invoice.attach(params[:vendor][:sample_sales_invoice]) if params[:vendor][:sample_sales_invoice].present?
      
      redirect_to inventory_sales_vendor_path(@vendor), notice: "Vendor was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vendor.update(vendor_params)
      # Handle file attachments
      if params[:vendor][:tax_certificate].present?
        @vendor.tax_certificate.purge if @vendor.tax_certificate.attached?
        @vendor.tax_certificate.attach(params[:vendor][:tax_certificate])
      end
      if params[:vendor][:sales_invoice].present?
        @vendor.sales_invoice.purge if @vendor.sales_invoice.attached?
        @vendor.sales_invoice.attach(params[:vendor][:sales_invoice])
      end
      if params[:vendor][:vendor_quotation].present?
        @vendor.vendor_quotation.purge if @vendor.vendor_quotation.attached?
        @vendor.vendor_quotation.attach(params[:vendor][:vendor_quotation])
      end
      if params[:vendor][:sample_sales_invoice].present?
        @vendor.sample_sales_invoice.purge if @vendor.sample_sales_invoice.attached?
        @vendor.sample_sales_invoice.attach(params[:vendor][:sample_sales_invoice])
      end
      
      redirect_to inventory_sales_vendor_path(@vendor), notice: "Vendor was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vendor.destroy
    redirect_to inventory_sales_vendors_path, notice: "Vendor was successfully deleted."
  end

  def delete_sample_sales_invoice
    @vendor = Vendor.find(params[:id])
    @vendor.sample_sales_invoice.purge
    head :ok
  end

  private

  def set_vendor
    @vendor = Vendor.find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(:name, :address, :tin, :bank_details, :status, :tax_certificate, :sales_invoice, :vendor_quotation, :sample_sales_invoice)
  end
end

