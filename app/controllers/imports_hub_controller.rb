# frozen_string_literal: true

class ImportsHubController < ApplicationController
  before_action :authenticate_user!

  def show
    @programs = current_user.programs.order(:name)
    @active_tab = normalized_tab(params[:tab])
    @selected_program_id = params[:program_id]
  end

  private

  def normalized_tab(tab)
    return "costs" if tab.blank?
    return tab if %w[costs milestones delivery_units].include?(tab)

    "costs"
  end
end
