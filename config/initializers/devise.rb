Devise.setup do |config|
  # config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.navigational_formats = [:json]
  config.authentication_keys = [ :login ]
  config.confirmation_keys = [ :username ]
  config.reset_password_keys = [ :username ]
end