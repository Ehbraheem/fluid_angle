class AuthController < ApplicationController
  before_action :authenticate_user!, only: [:checkme]
  def whoami
    json_response
  end

  def checkme
    json_response
  end

  private

  def json_response
    render json: current_user || {}
  end
end
