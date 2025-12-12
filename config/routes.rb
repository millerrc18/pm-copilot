Rails.application.routes.draw do
  devise_for :users

  resources :programs do
    resources :contracts, shallow: true do
      resources :contract_periods, shallow: true
      resources :period_imports, only: [:new, :create]
      resources :delivery_milestones
      resources :delivery_units
      resources :delivery_unit_imports, only: [:new, :create]
      resources :cost_imports, only: [:new, :create]
      resources :milestone_imports, only: [:new, :create]

    end
  end

  authenticated :user do
    root to: "programs#index", as: :authenticated_root
  end

  unauthenticated do
    root to: redirect("/users/sign_in"), as: :unauthenticated_root
  end
end
