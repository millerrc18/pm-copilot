Rails.application.routes.draw do
  get "period_imports/new"
  get "period_imports/create"
  resources :programs do
    resources :contracts, shallow: true do
      resources :contract_periods, shallow: true
      resources :period_imports, only: [:new, :create]
    end
  end

  root "programs#index"
end
