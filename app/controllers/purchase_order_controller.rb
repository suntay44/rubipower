class PurchaseOrderController < ApplicationController
  def index
  end

  def purchase_request
    # This will be used to display the list of purchase requests
    # For now, we'll create some sample data
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
        status: "Approved",
        created_at: "2024-01-14"
      },
      {
        id: 3,
        requester: "Mike Johnson",
        department: "Maintenance",
        items: "Tools and Supplies",
        estimated_cost: 15000,
        status: "Rejected",
        created_at: "2024-01-13"
      }
    ]
  end

  def new_purchase_request
    # This will be used to display the new purchase request form
    @departments = [ "Engineering", "Operations", "Maintenance", "IT", "Finance", "HR", "Sales", "Marketing" ]
    @priority_levels = [ "Low", "Medium", "High", "Urgent" ]
  end
end
