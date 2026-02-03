class PlanningHubController < ApplicationController
  before_action :authenticate_user!

  def index
    @programs = current_user.programs.order(:name)
    @selected_program = @programs.find_by(id: params[:program_id]) if params[:program_id].present?
    @selected_type = params[:item_type].presence

    program_scope = @selected_program ? Program.where(id: @selected_program.id) : @programs
    @timeline_items = Planning::TimelineBuilder.new(
      programs: program_scope,
      item_type: @selected_type
    ).call
  end
end
