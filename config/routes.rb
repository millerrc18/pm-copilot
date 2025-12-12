Rails.application.routes.draw do
  resources :programs do
    resources :contracts, shallow: true do
      resources :contract_periods, shallow: true
    end
  end

  root "programs#index"
end
