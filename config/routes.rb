Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do
    resources :foos
    mount_devise_token_auth_for 'User', at: 'user'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
