Rails.application.routes.draw do
  devise_for :users
  resource :theme_preference, only: [:update]

  namespace :admin do
    resources :users, only: [:index]
  end

  get "profile", to: "users#profile"
  get "account", to: "users#profile"

  get "docs", to: "docs#index"
  get "docs/:slug", to: "docs#show", as: :doc
  get "search", to: "search#index"

  resources :contracts, only: [:index]
  resources :delivery_milestones, only: [:index, :new]
  resources :delivery_units, only: [:index, :new]
  resources :proposals, only: [:index, :new]

  resources :programs do
    resources :contracts, shallow: true do
      resources :contract_periods, shallow: true
      resources :delivery_milestones
      resources :delivery_units
    end
  end

  get "imports", to: "imports_hub#show", as: :imports_hub
  get "imports/templates/:template", to: "import_templates#show", as: :import_template

  get "cost-hub", to: "cost_entries#index", as: :cost_hub
  resources :cost_entries, only: [:index, :new, :create, :edit, :update, :destroy] do
    get :duplicate, on: :member
  end
  resources :cost_imports, only: [:new, :create]
  resources :milestone_imports, only: [:new, :create]
  resources :delivery_unit_imports, only: [:new, :create]

  root "programs#index"
end
