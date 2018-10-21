Devise.setup do |config|
  # config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.navigational_formats = [:json]
  config.authentication_keys = %i(login username email)
  config.reset_password_keys = [ :username ]
  config.confirmation_keys = [ :username ]
end