class OpsEfficiencySavedViewsController < ApplicationController
  def create
    current_user.update!(ops_efficiency_saved_filters: normalized_filters)
    redirect_to operations_efficiency_path(normalized_filters), notice: "Efficiency view saved as default."
  end

  def destroy
    current_user.update!(ops_efficiency_saved_filters: {})
    redirect_to operations_efficiency_path, notice: "Saved efficiency view cleared."
  end

  private

  def normalized_filters
    params.permit(:program_id, :labor_category, :work_center, :start_date, :end_date).to_h.compact_blank
  end
end
