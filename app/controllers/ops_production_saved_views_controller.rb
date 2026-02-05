class OpsProductionSavedViewsController < ApplicationController
  def create
    current_user.update!(ops_production_saved_filters: normalized_filters)
    redirect_to operations_production_path(normalized_filters), notice: "Production view saved as default."
  end

  def destroy
    current_user.update!(ops_production_saved_filters: {})
    redirect_to operations_production_path, notice: "Saved production view cleared."
  end

  private

  def normalized_filters
    params.permit(:program_id, :status, :work_center, :part_number, :order_number, :start_date, :end_date, :tab)
          .to_h.compact_blank
  end
end
