Rails.application.routes.draw do
  get "purchase_order/index"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Dashboard route (protected by authentication)
  get "/dashboard", to: "dashboard#index", as: :dashboard

  # Material Requisition Slip routes
  resources :material_requisition_slips do
    member do
      patch :approve_supervisor
      patch :reject_supervisor
      patch :approve_procurement
      patch :reject_procurement
      patch :approve_engineering
      patch :reject_engineering
      patch :approve_admin
      patch :reject_admin
      post :create_purchase_request
      delete :purge_proposal
    end
  end

  # Purchase Request Workflow
  get "/purchase-request", to: "purchase_request#index", as: :purchase_request
  get "/purchase-request/new", to: "purchase_request#new_purchase_request", as: :new_purchase_request
  post "/purchase-request", to: "purchase_request#create", as: :create_purchase_request
  get "/purchase-request/budget-approval", to: "purchase_request#budget_approval", as: :budget_approval
  get "/purchase-request/procurement-review", to: "purchase_request#procurement_review", as: :procurement_review
  get "/purchase-request/:id", to: "purchase_request#show", as: :purchase_request_detail
  get "/purchase-request/:id/edit", to: "purchase_request#edit", as: :edit_purchase_request
  patch "/purchase-request/:id", to: "purchase_request#update", as: :update_purchase_request
  patch "/purchase-request/:id/approve-manager", to: "purchase_request#approve_manager", as: :approve_manager_purchase_request
  patch "/purchase-request/:id/approve-finance", to: "purchase_request#approve_finance", as: :approve_finance_purchase_request
  post "/purchase-request/:id/create-purchase-order", to: "purchase_order#create", as: :create_purchase_order
  get "/purchase-request/:id/purchase-order", to: "purchase_order#show_by_request", as: :purchase_request_purchase_order

  # Purchase Order routes
  get "/purchase-order/:id", to: "purchase_order#show", as: :purchase_order
  patch "/purchase-order/:id/update-status", to: "purchase_order#update_status", as: :update_purchase_order_status

  # Cash Advance Request routes
  get "/cash-advance-request", to: "cash_advance_request#index", as: :cash_advance_requests
  get "/cash-advance-request/new", to: "cash_advance_request#new", as: :new_cash_advance_request
  post "/cash-advance-request", to: "cash_advance_request#create", as: :create_cash_advance_request
  get "/cash-advance-request/:id", to: "cash_advance_request#show", as: :cash_advance_request
  get "/cash-advance-request/:id/edit", to: "cash_advance_request#edit", as: :edit_cash_advance_request
  patch "/cash-advance-request/:id", to: "cash_advance_request#update", as: :update_cash_advance_request
  patch "/cash-advance-request/:id/approve-manager", to: "cash_advance_request#approve_manager", as: :approve_manager_cash_advance
  patch "/cash-advance-request/:id/revise-manager", to: "cash_advance_request#revise_manager", as: :revise_manager_cash_advance
  patch "/cash-advance-request/:id/reject-manager", to: "cash_advance_request#reject_manager", as: :reject_manager_cash_advance
  patch "/cash-advance-request/:id/approve-finance", to: "cash_advance_request#approve_finance", as: :approve_finance_cash_advance
  patch "/cash-advance-request/:id/reject-finance", to: "cash_advance_request#reject_finance", as: :reject_finance_cash_advance
  delete "/cash-advance-request/:id/delete-attachment/:attachment_id", to: "cash_advance_request#delete_attachment", as: :delete_attachment_cash_advance

  # Expense Report routes
  get "/cash-advance-request/:id/expense-report", to: "expense_report#show", as: :expense_report
  get "/cash-advance-request/:id/expense-report/new", to: "expense_report#new", as: :new_expense_report
  post "/cash-advance-request/:id/expense-report", to: "expense_report#create"
  get "/expense-report/:id/edit", to: "expense_report#edit", as: :edit_expense_report
  patch "/expense-report/:id", to: "expense_report#update"
  delete "/expense-report/:id/delete-attachment/:attachment_id", to: "expense_report#delete_attachment", as: :delete_attachment_expense_report

  # Invoice routes
  resources :invoices
  delete "/invoices/:id/delete-attachment/:attachment_id", to: "invoices#delete_attachment", as: :delete_attachment_invoice

  # Employee Reimbursement routes
  resources :employee_reimbursements, path: "employee-reimbursements"
  delete "/employee-reimbursements/:id/delete-receipt/:attachment_id", to: "employee_reimbursements#delete_receipt", as: :delete_receipt_employee_reimbursement
  delete "/employee-reimbursements/:id/delete-proof/:attachment_id", to: "employee_reimbursements#delete_proof", as: :delete_proof_employee_reimbursement
  delete "/employee-reimbursements/:id/delete-itinerary/:attachment_id", to: "employee_reimbursements#delete_itinerary", as: :delete_itinerary_employee_reimbursement
  patch "/employee-reimbursements/:id/approve-supervisor", to: "employee_reimbursements#approve_supervisor", as: :approve_supervisor_employee_reimbursement
  patch "/employee-reimbursements/:id/revise-supervisor", to: "employee_reimbursements#revise_supervisor", as: :revise_supervisor_employee_reimbursement
  patch "/employee-reimbursements/:id/reject-supervisor", to: "employee_reimbursements#reject_supervisor", as: :reject_supervisor_employee_reimbursement
  patch "/employee-reimbursements/:id/approve-finance", to: "employee_reimbursements#approve_finance", as: :approve_finance_employee_reimbursement
  patch "/employee-reimbursements/:id/reject-finance", to: "employee_reimbursements#reject_finance", as: :reject_finance_employee_reimbursement

  # Expense/Revenue Encoding routes
  resources :expense_revenues, path: "expense-revenues"
  delete "/expense-revenues/:id/delete-receipt/:attachment_id", to: "expense_revenues#delete_receipt", as: :delete_receipt_expense_revenue
  delete "/expense-revenues/:id/delete-supporting-document/:attachment_id", to: "expense_revenues#delete_supporting_document", as: :delete_supporting_document_expense_revenue
  patch "/expense-revenues/:id/approve-supervisor", to: "expense_revenues#approve_supervisor", as: :approve_supervisor_expense_revenue
  patch "/expense-revenues/:id/reject-supervisor", to: "expense_revenues#reject_supervisor", as: :reject_supervisor_expense_revenue
  patch "/expense-revenues/:id/approve-finance", to: "expense_revenues#approve_finance", as: :approve_finance_expense_revenue
  patch "/expense-revenues/:id/reject-finance", to: "expense_revenues#reject_finance", as: :reject_finance_expense_revenue

  # HR & Payroll routes
  get "/hr-payroll", to: "hr_payroll#index", as: :hr_payroll
  get "/hr-payroll/time-tracking", to: "hr_payroll#time_tracking", as: :hr_payroll_time_tracking
  post "/hr-payroll/time-tracking/clock_in", to: "hr_payroll#clock_in", as: :hr_payroll_clock_in
  post "/hr-payroll/time-tracking/clock_out", to: "hr_payroll#clock_out", as: :hr_payroll_clock_out
  get "/hr-payroll/payslips", to: "hr_payroll#payslips", as: :hr_payroll_payslips
  get "/hr-payroll/leaves", to: "hr_payroll#leaves", as: :hr_payroll_leaves
  get "/hr-payroll/attendance", to: "hr_payroll#attendance", as: :hr_payroll_attendance
  get "/hr-payroll/employee-records", to: "hr_payroll#employee_records", as: :hr_payroll_employee_records
  get "/hr-payroll/payroll-reports", to: "hr_payroll#payroll_reports", as: :hr_payroll_payroll_reports
  get "/hr-payroll/user-management", to: "hr_payroll#user_management", as: :hr_payroll_user_management
  get "/hr-payroll/user-management/new", to: "hr_payroll#new_user", as: :new_hr_payroll_user
  post "/hr-payroll/user-management", to: "hr_payroll#create_user", as: :create_hr_payroll_user
  get "/hr-payroll/user-management/:id/edit", to: "hr_payroll#edit_user", as: :edit_hr_payroll_user
  patch "/hr-payroll/user-management/:id", to: "hr_payroll#update_user", as: :update_hr_payroll_user
  delete "/hr-payroll/user-management/:id", to: "hr_payroll#destroy_user", as: :destroy_hr_payroll_user

  # Inventory & Sales routes
  get "/inventory-and-sales", to: "inventory_sales#index", as: :inventory_sales
  get "/inventory-and-sales/products", to: "inventory_sales#products", as: :inventory_sales_products
  get "/inventory-and-sales/products/new", to: "inventory_sales#new_product", as: :new_inventory_sales_product
  post "/inventory-and-sales/products", to: "inventory_sales#create_product", as: :inventory_sales_products_create
  get "/inventory-and-sales/products/:id", to: "inventory_sales#show_product", as: :inventory_sales_product
  get "/inventory-and-sales/products/:id/edit", to: "inventory_sales#edit_product", as: :edit_inventory_sales_product
  patch "/inventory-and-sales/products/:id", to: "inventory_sales#update_product", as: :inventory_sales_product_update
  delete "/inventory-and-sales/products/:id", to: "inventory_sales#destroy_product", as: :inventory_sales_product_destroy
  get "/inventory-and-sales/sales", to: "sales#index", as: :inventory_sales_sales
  get "/inventory-and-sales/sales/new", to: "sales#new", as: :new_inventory_sales_sale
  post "/inventory-and-sales/sales", to: "sales#create", as: :create_inventory_sales_sale
  get "/inventory-and-sales/sales/:id", to: "sales#show", as: :inventory_sales_sale
  get "/inventory-and-sales/sales/:id/edit", to: "sales#edit", as: :edit_inventory_sales_sale
  patch "/inventory-and-sales/sales/:id", to: "sales#update", as: :update_inventory_sales_sale
  delete "/inventory-and-sales/sales/:id", to: "sales#destroy", as: :destroy_inventory_sales_sale
  get "/inventory-and-sales/customers", to: "inventory_sales#customers", as: :inventory_sales_customers
  get "/inventory-and-sales/customers/new", to: "inventory_sales#new_customer", as: :new_inventory_sales_customer
  post "/inventory-and-sales/customers", to: "inventory_sales#create_customer", as: :create_inventory_sales_customer
  get "/inventory-and-sales/customers/:id/edit", to: "inventory_sales#edit_customer", as: :edit_inventory_sales_customer
  patch "/inventory-and-sales/customers/:id", to: "inventory_sales#update_customer", as: :update_inventory_sales_customer
  delete "/inventory-and-sales/customers/:id", to: "inventory_sales#destroy_customer", as: :destroy_inventory_sales_customer
  get "/inventory-and-sales/orders", to: "inventory_sales#orders", as: :inventory_sales_orders
  get "/inventory-and-sales/orders/new", to: "inventory_sales#new_order", as: :new_inventory_sales_order
  post "/inventory-and-sales/orders", to: "inventory_sales#create_order", as: :create_inventory_sales_order
  get "/inventory-and-sales/orders/:id", to: "inventory_sales#show_order", as: :inventory_sales_order
  get "/inventory-and-sales/orders/:id/edit", to: "inventory_sales#edit_order", as: :edit_inventory_sales_order
  patch "/inventory-and-sales/orders/:id", to: "inventory_sales#update_order", as: :update_inventory_sales_order
  delete "/inventory-and-sales/orders/:id", to: "inventory_sales#destroy_order", as: :destroy_inventory_sales_order
  get "/inventory-and-sales/reports", to: "inventory_sales#reports", as: :inventory_sales_reports
  
  # Vendor routes
  get "/inventory-and-sales/vendors", to: "vendors#index", as: :inventory_sales_vendors
  get "/inventory-and-sales/vendors/new", to: "vendors#new", as: :new_inventory_sales_vendor
  post "/inventory-and-sales/vendors", to: "vendors#create", as: :create_inventory_sales_vendor
  get "/inventory-and-sales/vendors/:id", to: "vendors#show", as: :inventory_sales_vendor
  get "/inventory-and-sales/vendors/:id/edit", to: "vendors#edit", as: :edit_inventory_sales_vendor
  patch "/inventory-and-sales/vendors/:id", to: "vendors#update", as: :update_inventory_sales_vendor
  delete "/inventory-and-sales/vendors/:id", to: "vendors#destroy", as: :destroy_inventory_sales_vendor
  delete "/inventory-and-sales/vendors/:id/delete_sample_sales_invoice", to: "vendors#delete_sample_sales_invoice", as: :delete_vendor_sample_sales_invoice
  
  # Material routes
  get "/inventory-and-sales/materials", to: "materials#index", as: :inventory_sales_materials
  get "/inventory-and-sales/materials/new", to: "materials#new", as: :new_inventory_sales_material
  post "/inventory-and-sales/materials", to: "materials#create", as: :create_inventory_sales_material
  get "/inventory-and-sales/materials/:id", to: "materials#show", as: :inventory_sales_material
  get "/inventory-and-sales/materials/:id/edit", to: "materials#edit", as: :edit_inventory_sales_material
  patch "/inventory-and-sales/materials/:id", to: "materials#update", as: :update_inventory_sales_material
  delete "/inventory-and-sales/materials/:id", to: "materials#destroy", as: :destroy_inventory_sales_material

  # Test pages (all protected by authentication)
  get "/home", to: "pages#home"
  get "/about", to: "pages#about"
  get "/contact", to: "pages#contact"
  get "/profile", to: "pages#profile"
  get "/settings", to: "pages#settings"

  # Defines the root path route ("/")
  # Redirect to dashboard page
  root "dashboard#index"
end
