class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  #   skip_before_action :verify_authenticity_token
  #   helper_method :current_user, :user_signed_in?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added_attrs = %i[nickname email password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
