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

  # Purchase Request Workflow
  get "/purchase-request", to: "purchase_request#index", as: :purchase_request
  get "/purchase-request/new", to: "purchase_request#new_purchase_request", as: :new_purchase_request
  post "/purchase-request", to: "purchase_request#create", as: :create_purchase_request
  get "/purchase-request/budget-approval", to: "purchase_request#budget_approval", as: :budget_approval
  get "/purchase-request/procurement-review", to: "purchase_request#procurement_review", as: :procurement_review
  get "/purchase-request/:id", to: "purchase_request#show", as: :purchase_request_detail
  get "/purchase-request/:id/create-purchase-order", to: "purchase_request#create_purchase_order", as: :create_purchase_order

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
