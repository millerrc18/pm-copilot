Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :users, only: [:index]
  end

  resources :cost_imports, only: [:new, :create]

  resources :programs do
    resources :contracts, shallow: true do
      resources :contract_periods, shallow: true
      resources :delivery_milestones
      resources :delivery_units
      resources :delivery_unit_imports, only: [:new, :create]
      resources :cost_imports, only: [:new, :create]
      resources :milestone_imports, only: [:new, :create]
    end
  end

  root "programs#index"
end
