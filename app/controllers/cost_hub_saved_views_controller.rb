class CostHubSavedViewsController < ApplicationController
  def create
    filters = normalized_filters
    current_user.update!(cost_hub_saved_filters: filters)
    redirect_to cost_hub_path(filters), notice: "Cost Hub view saved as default."
  end

  def destroy
    current_user.update!(cost_hub_saved_filters: {})
    redirect_to cost_hub_path, notice: "Saved Cost Hub view cleared."
  end

  private

  def normalized_filters
    start_date = parsed_date(params[:start_date])
    end_date = parsed_date(params[:end_date])
    program_id = normalized_program_id

    {
      "start_date" => start_date&.to_s,
      "end_date" => end_date&.to_s,
      "program_id" => program_id
    }.compact_blank
  end

  def parsed_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end

  def normalized_program_id
    return nil if params[:program_id].blank?

    program = current_user.programs.find_by(id: params[:program_id])
    program&.id&.to_s
  end
end
