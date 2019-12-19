Rails.application.routes.draw do
  resources :events
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'auth/discourse', controller: :auth, action: :discourse
  get 'auth_comeback/discourse', controller: :auth_comeback, action: :discourse

  root to: 'events#index'
end
