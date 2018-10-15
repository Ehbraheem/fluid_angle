class ApplicationController < ActionController::API
  # Intercept RecordNotFound exception and render JSON error response
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Intercept ActionController::ParameterMissing exception
  rescue_from ActionController::ParameterMissing, with: :param_missing

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
end
