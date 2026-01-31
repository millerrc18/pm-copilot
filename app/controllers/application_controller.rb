class ApplicationController < ActionController::Base
  layout "app_shell"
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception

  protected

  def configure_permitted_parameters
    profile_fields = %i[first_name last_name job_title company bio theme palette]
    devise_parameter_sanitizer.permit(:sign_up, keys: profile_fields)
    devise_parameter_sanitizer.permit(:account_update, keys: profile_fields)
  end

  def authorize_program_owner!(program)
    return if program.user_id == current_user.id

    redirect_to programs_path, alert: "Not authorized."
  end

  def authorize_contract_owner!(contract)
    authorize_program_owner!(contract.program)
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
