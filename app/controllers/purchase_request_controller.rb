class PurchaseRequestController < ApplicationController
  def index
    @purchase_requests = PurchaseRequest.includes(:requester_user, :items, :purchase_order).order(created_at: :desc)
    
    # Filter by approval status
    if params[:status].present?
      case params[:status]
      when 'pending_manager'
        @purchase_requests = @purchase_requests.where('manager_approved IS NULL OR manager_approved = ?', false)
      when 'pending_finance'
        @purchase_requests = @purchase_requests.where('finance_approved IS NULL OR finance_approved = ?', false)
      when 'both_approved'
        @purchase_requests = @purchase_requests.where(manager_approved: true, finance_approved: true)
      when 'pending_all'
        @purchase_requests = @purchase_requests.where('(manager_approved IS NULL OR manager_approved = ?) AND (finance_approved IS NULL OR finance_approved = ?)', false, false)
      end
    end
    
    # Filter by priority
    if params[:priority].present?
      @purchase_requests = @purchase_requests.where(priority_level: params[:priority])
    end
    
    # Filter by department (from requester)
    if params[:department].present?
      @purchase_requests = @purchase_requests.joins(:requester_user).where(users: { department: params[:department].downcase })
    end
  end

  def show
    @purchase_request = PurchaseRequest.includes(:requester_user, {:items => :vendor}, :purchase_order, :material_requisition_slip).find(params[:id])
  end

  def edit
    @purchase_request = PurchaseRequest.includes(:requester_user, :items).find(params[:id])
    @departments = User.departments.keys.map(&:titleize)
    @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
  end

  def update
    @purchase_request = PurchaseRequest.find(params[:id])

    if @purchase_request.update(purchase_request_params)
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
    
    # Load approved MRSs for selection
    @approved_mrs_list = MaterialRequisitionSlip.includes(:requester_user, :items_exclusive => :vendor)
                                                  .where(supervisor_approved: true, procurement_approved: true, engineering_approved: true, admin_approved: true)
                                                  .recent
                                                  .limit(50)
                                                  .to_a
    
    # Pre-fill from MRS if coming from Material Requisition Slip
    # Prioritize params[:mrs_id] over session data
    if params[:mrs_id].present?
      # Load MRS data from query parameter (from "Create Purchase Request" button or dropdown selection)
      load_mrs_data(params[:mrs_id])
      # Store MRS ID in session to be used in create action
      session[:mrs_id] = params[:mrs_id]
      # Clear session data if it exists
      session.delete(:mrs_data) if session[:mrs_data].present?
    elsif session[:mrs_data].present?
      # Fallback to session data if no params (for backwards compatibility)
      mrs_data = session[:mrs_data]
      # Handle both symbol and string keys
      mrs_id = mrs_data[:mrs_id] || mrs_data["mrs_id"]
      
      if mrs_id.present?
        begin
          @mrs = MaterialRequisitionSlip.includes(:items_exclusive => :vendor).find(mrs_id)
          @purchase_request.request_date = mrs_data[:request_date] || mrs_data["request_date"]
          @purchase_request.priority_level = mrs_data[:priority_level] || mrs_data["priority_level"]
          @purchase_request.reason_for_purchase = mrs_data[:reason_for_purchase] || mrs_data["reason_for_purchase"]
          @purchase_request.material_requisition_slip_id = mrs_id
          
          # Pre-populate items from MRS (use items_exclusive from the loaded MRS)
          @mrs.items_exclusive.each do |item|
            @purchase_request.items.build(
              name: item.name,
              description: item.description,
              quantity: item.quantity,
              quoted_price: item.quoted_price,
              vendor_id: item.vendor_id
              # Don't set material_requisition_slip_id - items for PR should only have purchase_request_id
            )
          end
          
          # Always build at least one item if none exist
          @purchase_request.items.build if @purchase_request.items.empty?
          
          # Store MRS ID in session to be used in create action
          session[:mrs_id] = mrs_id
          session.delete(:mrs_data)
        rescue ActiveRecord::RecordNotFound
          flash[:alert] = "Material Requisition Slip not found. Please select a valid MRS."
          session.delete(:mrs_data)
        end
      else
        flash[:alert] = "Invalid Material Requisition Slip data. Please try again."
        session.delete(:mrs_data)
      end
    end
  end

  def load_mrs_data(mrs_id)
    @mrs = MaterialRequisitionSlip.includes(:items_exclusive => :vendor).find(mrs_id)
    @purchase_request.request_date = @mrs.request_date
    @purchase_request.priority_level = @mrs.priority_level
    @purchase_request.reason_for_purchase = @mrs.purpose
    @purchase_request.material_requisition_slip_id = @mrs.id
    
    @mrs.items_exclusive.each do |item|
      @purchase_request.items.build(
        name: item.name,
        description: item.description,
        quantity: item.quantity,
        quoted_price: item.quoted_price,
        vendor_id: item.vendor_id
        # Don't set material_requisition_slip_id - items for PR should only have purchase_request_id
      )
    end
    
    @purchase_request.items.build if @purchase_request.items.empty?
  end

  def create
    @purchase_request = current_user.purchase_requests.build(purchase_request_params)
    
    # Set MRS ID from session if present
    if session[:mrs_id].present?
      mrs_id = session[:mrs_id]
      @purchase_request.material_requisition_slip_id = mrs_id
      session.delete(:mrs_id)
    end

    if @purchase_request.save
      redirect_to purchase_request_detail_path(@purchase_request), notice: "Purchase request was successfully created."
    else
      @departments = User.departments.keys.map(&:titleize)
      @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
      @approved_mrs_list = MaterialRequisitionSlip.includes(:requester_user, :items => :vendor)
                                                    .where(supervisor_approved: true, procurement_approved: true, engineering_approved: true, admin_approved: true)
                                                    .recent
                                                    .limit(50)
                                                    .to_a
      render :new_purchase_request, status: :unprocessable_entity
    end
  end

  def approve_manager
    @purchase_request = PurchaseRequest.find(params[:id])
    
    # Manager approval: Any user with Manager role (any department)
    if current_user.manager? && !@purchase_request.manager_approved?
      @purchase_request.update(
        manager_approved: true,
        manager_approved_by: current_user.id,
        manager_approved_at: Time.current
      )
      redirect_to purchase_request_detail_path(@purchase_request), notice: "Manager approval granted."
    else
      redirect_to purchase_request_detail_path(@purchase_request), alert: "You are not authorized to approve this request or it has already been approved."
    end
  end

  def approve_finance
    @purchase_request = PurchaseRequest.find(params[:id])
    
    # Finance approval: Admin role AND Finance department
    if current_user.admin? && current_user.department_finance? && !@purchase_request.finance_approved?
      @purchase_request.update(
        finance_approved: true,
        finance_approved_by: current_user.id,
        finance_approved_at: Time.current
      )
      redirect_to purchase_request_detail_path(@purchase_request), notice: "Finance approval granted."
    else
      redirect_to purchase_request_detail_path(@purchase_request), alert: "You are not authorized to approve this request. Only Admins with Finance department can approve, or it has already been approved."
    end
  end

  def create_purchase_order
    # Find the specific purchase request by ID from the database
    @purchase_request = PurchaseRequest.includes(:requester_user, :items).find(params[:id])

    # Check if both approvals are present
    unless @purchase_request.all_approvals_complete?
      redirect_to purchase_request_detail_path(@purchase_request), alert: "Both Manager and Admin/Finance approvals are required to create a purchase order."
      return
    end

    # For now, just redirect back with a success message
    # In the future, this would create an actual purchase order
    redirect_to purchase_request_detail_path(@purchase_request), notice: "Purchase order creation functionality will be implemented soon."
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
      :material_requisition_slip_id,
      items_attributes: [ :id, :name, :description, :quantity, :quoted_price, :vendor_id, :_destroy ]
    )
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
