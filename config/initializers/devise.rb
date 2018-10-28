Devise.setup do |config|
  # config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.navigational_formats = [:json]
  config.authentication_keys = %i(login username email)
  config.reset_password_keys = [ :username ]
  config.confirmation_keys = [ :username ]
  config.secret_key = 'a502c9149f015de89a50605b5b09af854a9f6336ed556dc5ad2c97cb16efbcb0b3a30712e33cfa2828cf384a78d53393ae754a8970c99a695cd1a65d57bf43a3'
end