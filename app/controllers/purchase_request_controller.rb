class PurchaseRequestController < ApplicationController
  def index
    @purchase_requests = PurchaseRequest.includes(:requester_user, :items, :purchase_order).order(created_at: :desc)
  end

  def show
    @purchase_request = PurchaseRequest.includes(:requester_user, :items, :purchase_order).find(params[:id])
  end

  def edit
    @purchase_request = PurchaseRequest.includes(:requester_user, :items).find(params[:id])
    @departments = User.departments.keys.map(&:titleize)
    @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
  end

  def update
    @purchase_request = PurchaseRequest.find(params[:id])

    if @purchase_request.update(purchase_request_params)
      # Handle file attachments - replace existing ones
      @purchase_request.tax_certificate.purge if @purchase_request.tax_certificate.attached? && params[:purchase_request][:tax_certificate].present?
      @purchase_request.sales_invoice.purge if @purchase_request.sales_invoice.attached? && params[:purchase_request][:sales_invoice].present?
      @purchase_request.vendor_quotation.purge if @purchase_request.vendor_quotation.attached? && params[:purchase_request][:vendor_quotation].present?

      @purchase_request.tax_certificate.attach(params[:purchase_request][:tax_certificate]) if params[:purchase_request][:tax_certificate].present?
      @purchase_request.sales_invoice.attach(params[:purchase_request][:sales_invoice]) if params[:purchase_request][:sales_invoice].present?
      @purchase_request.vendor_quotation.attach(params[:purchase_request][:vendor_quotation]) if params[:purchase_request][:vendor_quotation].present?

      redirect_to purchase_request_detail_path(@purchase_request), notice: "Purchase request was successfully updated."
    else
      @departments = User.departments.keys.map(&:titleize)
      @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
      render :edit, status: :unprocessable_entity
    end
  end

  def approve_budget
    @purchase_request = PurchaseRequest.find(params[:id])
    new_status = !@purchase_request.budget_approve?
    @purchase_request.update(budget_approve: new_status)

    if new_status
      redirect_to purchase_request_detail_path(@purchase_request), notice: "Budget has been approved."
    else
      redirect_to purchase_request_detail_path(@purchase_request), notice: "Budget approval has been revoked."
    end
  end

  def approve_procurement
    @purchase_request = PurchaseRequest.find(params[:id])
    new_status = !@purchase_request.procurement_approve?
    @purchase_request.update(procurement_approve: new_status)

    if new_status
      redirect_to purchase_request_detail_path(@purchase_request), notice: "Procurement has been approved."
    else
      redirect_to purchase_request_detail_path(@purchase_request), notice: "Procurement approval has been revoked."
    end
  end

  def delete_tax_certificate
    @purchase_request = PurchaseRequest.find(params[:id])
    @purchase_request.tax_certificate.purge
    head :ok
  end

  def delete_sales_invoice
    @purchase_request = PurchaseRequest.find(params[:id])
    @purchase_request.sales_invoice.purge
    head :ok
  end

  def delete_vendor_quotation
    @purchase_request = PurchaseRequest.find(params[:id])
    @purchase_request.vendor_quotation.purge
    head :ok
  end

  def new_purchase_request
    # This will be used to display the new purchase request form
    @departments = User.departments.keys.map(&:titleize)
    @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
    @purchase_request = PurchaseRequest.new
    @purchase_request.items.build
  end

  def create
    @purchase_request = current_user.purchase_requests.build(purchase_request_params)

    if @purchase_request.save
      # Handle file attachments
      @purchase_request.tax_certificate.attach(params[:purchase_request][:tax_certificate]) if params[:purchase_request][:tax_certificate].present?
      @purchase_request.sales_invoice.attach(params[:purchase_request][:sales_invoice]) if params[:purchase_request][:sales_invoice].present?
      @purchase_request.vendor_quotation.attach(params[:purchase_request][:vendor_quotation]) if params[:purchase_request][:vendor_quotation].present?

      redirect_to purchase_request_detail_path(@purchase_request), notice: "Purchase request was successfully created."
    else
      @departments = User.departments.keys.map(&:titleize)
      @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
      render :new_purchase_request, status: :unprocessable_entity
    end
  end

  private

  def purchase_request_params
    params.require(:purchase_request).permit(
      :request_date,
      :priority_level,
      :reason_for_purchase,
      :sales_order_number,
      :client_name,
      :additional_notes,
      :vendor_name,
      :vendor_address,
      :bank_details,
      :tax_certificate,
      :sales_invoice,
      :vendor_quotation,
      items_attributes: [ :id, :description, :quantity, :cost, :_destroy ]
    )
  end

  def create_purchase_order
    # Find the specific purchase request by ID from the database
    @purchase_request = PurchaseRequest.includes(:requester_user, :items).find(params[:id])

    # Check if both approvals are present
    unless @purchase_request.budget_approve? && @purchase_request.procurement_approve?
      redirect_to purchase_request_detail_path(@purchase_request), alert: "Both budget and procurement approvals are required to create a purchase order."
      return
    end

    # For now, just redirect back with a success message
    # In the future, this would create an actual purchase order
    redirect_to purchase_request_detail_path(@purchase_request), notice: "Purchase order creation functionality will be implemented soon."
  end

  def budget_approval
    # This will be used to display the budget approval page
    @purchase_requests = [
      {
        id: 1,
        requester: "John Doe",
        department: "Engineering",
        items: "Electrical Equipment",
        estimated_cost: 50000,
        status: "Pending",
        created_at: "2024-01-15"
      },
      {
        id: 2,
        requester: "Jane Smith",
        department: "Operations",
        items: "Safety Equipment",
        estimated_cost: 25000,
        status: "Pending",
        created_at: "2024-01-14"
      },
      {
        id: 3,
        requester: "Mike Johnson",
        department: "Maintenance",
        items: "Tools and Supplies",
        estimated_cost: 15000,
        status: "Pending",
        created_at: "2024-01-13"
      }
    ]
  end

  def procurement_review
    # This will be used to display the procurement review page
    @purchase_requests = [
      {
        id: 1,
        requester: "John Doe",
        department: "Engineering",
        items: "Electrical Equipment",
        estimated_cost: 50000,
        status: "Budget Approved",
        created_at: "2024-01-15"
      },
      {
        id: 2,
        requester: "Jane Smith",
        department: "Operations",
        items: "Safety Equipment",
        estimated_cost: 25000,
        status: "Budget Approved",
        created_at: "2024-01-14"
      },
      {
        id: 3,
        requester: "Mike Johnson",
        department: "Maintenance",
        items: "Tools and Supplies",
        estimated_cost: 15000,
        status: "Budget Approved",
        created_at: "2024-01-13"
      }
    ]
  end
end
