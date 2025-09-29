class PurchaseRequestController < ApplicationController
  def index
    @purchase_requests = PurchaseRequest.includes(:requester_user, :items).order(created_at: :desc)
  end

  def show
    @purchase_request = PurchaseRequest.includes(:requester_user, :items, :attachments_attachments).find(params[:id])
  end

  def new_purchase_request
    # This will be used to display the new purchase request form
    @departments = [ "Engineering", "Operations", "Maintenance", "IT", "Finance", "HR", "Sales", "Marketing" ]
    @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
    @purchase_request = PurchaseRequest.new
    @purchase_request.items.build
  end

  def create
    @purchase_request = current_user.purchase_requests.build(purchase_request_params)

    if @purchase_request.save
      # Handle file attachments
      if params[:purchase_request][:attachments].present?
        params[:purchase_request][:attachments].each do |attachment|
          @purchase_request.attachments.attach(attachment)
        end
      end

      redirect_to purchase_request_detail_path(@purchase_request), notice: "Purchase request was successfully created."
    else
      @departments = [ "Engineering", "Operations", "Maintenance", "IT", "Finance", "HR", "Sales", "Marketing" ]
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
      items_attributes: [ :id, :description, :quantity, :cost, :_destroy ],
      attachments: []
    )
  end

  def create_purchase_order
    # Find the specific purchase request by ID
    all_requests = [
      {
        id: 1,
        requester: "John Doe",
        department: "Engineering",
        items: "Electrical Equipment",
        description: "Purchase of electrical equipment for the new project installation.",
        estimated_cost: 50000,
        engineering_budget_status: "Approved",
        procurement_review_status: "Approved",
        created_at: "2024-01-15",
        purchase_order_created: false
      },
      {
        id: 2,
        requester: "Jane Smith",
        department: "Operations",
        items: "Safety Equipment",
        description: "Safety equipment for warehouse operations including helmets, gloves, and safety vests.",
        estimated_cost: 25000,
        engineering_budget_status: "Approved",
        procurement_review_status: "Approved",
        created_at: "2024-01-14",
        purchase_order_created: true
      },
      {
        id: 3,
        requester: "Mike Johnson",
        department: "Maintenance",
        items: "Tools and Supplies",
        description: "Various tools and maintenance supplies for equipment repair and upkeep.",
        estimated_cost: 15000,
        engineering_budget_status: "Approved",
        procurement_review_status: "Approved",
        created_at: "2024-01-13",
        purchase_order_created: false
      }
    ]

    @request = all_requests.find { |req| req[:id] == params[:id].to_i }
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
