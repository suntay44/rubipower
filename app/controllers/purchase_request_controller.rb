class PurchaseRequestController < ApplicationController
  def index
    # This will be used to display the list of purchase requests
    # For now, we'll create some sample data
    @purchase_requests = [
      {
        id: 1,
        requester: "John Doe",
        department: "Engineering",
        items: "Electrical Equipment",
        estimated_cost: 50000,
        engineering_budget_status: "Pending",
        procurement_review_status: "Pending",
        created_at: "2024-01-15"
      },
      {
        id: 2,
        requester: "Jane Smith",
        department: "Operations",
        items: "Safety Equipment",
        estimated_cost: 25000,
        engineering_budget_status: "Approved",
        procurement_review_status: "Pending",
        created_at: "2024-01-14"
      },
      {
        id: 3,
        requester: "Mike Johnson",
        department: "Maintenance",
        items: "Tools and Supplies",
        estimated_cost: 15000,
        engineering_budget_status: "Approved",
        procurement_review_status: "Approved",
        created_at: "2024-01-13"
      }
    ]
  end

  def show
    # Find the specific purchase request by ID
    all_requests = [
      {
        id: 1,
        requester: "John Doe",
        department: "Engineering",
        items: "Electrical Equipment",
        description: "Purchase of electrical equipment for the new project installation.",
        estimated_cost: 50000,
        engineering_budget_status: "Pending",
        procurement_review_status: "Pending",
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

  def new_purchase_request
    # This will be used to display the new purchase request form
    @departments = [ "Engineering", "Operations", "Maintenance", "IT", "Finance", "HR", "Sales", "Marketing" ]
    @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
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
