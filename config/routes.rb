Rails.application.routes.draw do
  get 'auth/whoami'
  get 'auth/checkme'
  resources :contacts
  scope :api, defaults: {format: :json} do
    resources :foos
    mount_devise_token_auth_for 'User', at: 'user'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
