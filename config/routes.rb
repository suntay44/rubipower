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

  # Purchase Order Workflow
  get "/purchase-order", to: "purchase_order#index", as: :purchase_order
  get "/purchase-order/purchase-request", to: "purchase_order#purchase_request", as: :purchase_request
  get "/purchase-order/purchase-request/new", to: "purchase_order#new_purchase_request", as: :new_purchase_request

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
