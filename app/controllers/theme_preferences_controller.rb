class ThemePreferencesController < ApplicationController
  before_action :authenticate_user!

  def update
    theme = params.dig(:user, :theme)
    palette = params.dig(:user, :palette)

    updates = {}
    updates[:theme] = theme if User::THEME_OPTIONS.include?(theme)
    updates[:palette] = palette if User::PALETTE_OPTIONS.include?(palette)

    if updates.any?
      current_user.update(updates)
      flash[:notice] = "Appearance updated."
    else
      flash[:alert] = "Invalid appearance selection."
    end

    redirect_back fallback_location: root_path
  end
end
