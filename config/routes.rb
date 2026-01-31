Rails.application.routes.draw do
  devise_for :users
  resource :theme_preference, only: [:update]

  namespace :admin do
    resources :users, only: [:index]
  end

  get "docs", to: "docs#index"
  get "docs/:slug", to: "docs#show", as: :doc
  get "search", to: "search#index"

  resources :programs do
    resources :contracts, shallow: true do
      resources :contract_periods, shallow: true
      resources :delivery_milestones
      resources :delivery_units
      resources :delivery_unit_imports, only: [:new, :create]
      resources :milestone_imports, only: [:new, :create]
    end
  end

  get "cost-hub", to: "cost_entries#index", as: :cost_hub
  resources :cost_imports, only: [:new, :create]

  root "programs#index"
end
