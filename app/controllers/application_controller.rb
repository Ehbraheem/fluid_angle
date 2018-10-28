class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  # make the connection between controller action and associated view
  include ActionController::ImplicitRender
  
  # Intercept RecordNotFound exception and render JSON error response
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Intercept ActionController::ParameterMissing exception
  rescue_from ActionController::ParameterMissing, with: :param_missing

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def record_not_found(exception)
    full_message "cannot find record with ID #{params[:id]}", :not_found
    Rails.logger.debug exception.message
  end

  def param_missing(exception)
    full_message exception.message, :bad_request
    Rails.logger.debug exception.message
  end

  def full_message(error, status)
    payload = {
      errors: { full_messages: [error] }
    }
    render json: payload, status: status
  end

  def configure_permitted_parameters
    added_attrs = %i(username email password password_confirmation remember_me name)
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: %i(login password password_confirmation)
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
