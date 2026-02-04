class PlanningHubSavedViewsController < ApplicationController
  before_action :authenticate_user!

  def create
    filters = normalized_filters
    current_user.update!(planning_hub_saved_filters: filters)
    redirect_to planning_hub_path(filters), notice: "Planning Hub view saved as default."
  end

  def destroy
    current_user.update!(planning_hub_saved_filters: {})
    redirect_to planning_hub_path, notice: "Saved Planning Hub view cleared."
  end

  private

  def normalized_filters
    program_id = normalized_program_id

    {
      "program_id" => program_id,
      "item_type" => params[:item_type].presence,
      "status" => params[:status].presence,
      "owner_id" => normalized_owner_id,
      "view" => params[:view].presence
    }.compact_blank
  end

  def normalized_program_id
    return nil if params[:program_id].blank?

    program = current_user.programs.find_by(id: params[:program_id])
    program&.id&.to_s
  end

  def normalized_owner_id
    return nil if params[:owner_id].blank?

    owner = User.find_by(id: params[:owner_id])
    owner&.id&.to_s
  end
end
