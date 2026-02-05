Rails.application.routes.draw do
  devise_for :users
  resource :theme_preference, only: [:update]

  namespace :admin do
    resources :users, only: [:index]
  end

  get "profile", to: "users#profile"
  patch "profile", to: "users#update"
  get "account", to: "users#profile"
  patch "account", to: "users#update"

  get "docs", to: "docs#index"
  get "docs/:slug", to: "docs#show", as: :doc
  get "search", to: "search#index"

  resources :contracts, only: [:index]
  resources :delivery_milestones, only: [:index, :new]
  resources :delivery_units, only: [:index, :new]
  resources :proposals, only: [:index, :new]
  resources :risks
  resource :risk_saved_view, only: [ :create, :destroy ]
  get "planning-hub", to: "planning_hub#index", as: :planning_hub
  resource :planning_hub_saved_view, only: [ :create, :destroy ]
  resources :plan_items, only: [ :create, :update, :destroy ]
  resources :plan_dependencies, only: [ :create, :destroy ]
  get "exports/cost-hub(.:format)", to: "exports#cost_hub", as: :cost_hub_export
  get "exports/risks(.:format)", to: "exports#risks", as: :risks_export

  resources :programs do
    resources :contracts, shallow: true do
      resources :contract_periods, shallow: true
      resources :delivery_milestones
      resources :delivery_units
    end
  end

  get "imports", to: "imports_hub#show", as: :imports_hub
  get "imports/templates/:template", to: "import_templates#show", as: :import_template
  resources :ops_imports, only: [ :index, :create, :destroy ]

  get "cost-hub", to: "cost_entries#index", as: :cost_hub
  resource :cost_hub_saved_view, only: [ :create, :destroy ]
  resources :cost_entries, only: [:index, :new, :create, :edit, :update, :destroy] do
    get :duplicate, on: :member
  end
  resources :cost_imports, only: [:new, :create]
  resources :milestone_imports, only: [:new, :create]
  resources :delivery_unit_imports, only: [:new, :create]

  namespace :operations do
    get "procurement", to: "procurement#index"
    get "production", to: "production#index"
    get "efficiency", to: "efficiency#index"
    get "quality", to: "quality#index"
    get "bom", to: "bom#index"
  end

  resource :ops_procurement_saved_view, only: [ :create, :destroy ]
  resource :ops_production_saved_view, only: [ :create, :destroy ]
  resource :ops_efficiency_saved_view, only: [ :create, :destroy ]
  resource :ops_quality_saved_view, only: [ :create, :destroy ]
  resource :ops_bom_saved_view, only: [ :create, :destroy ]

  root "programs#index"
end
