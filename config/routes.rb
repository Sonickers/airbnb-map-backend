Rails.application.routes.draw do
  root :to => 'home#index'
  scope :api do
    resources :places, only: [:index]
  end
end