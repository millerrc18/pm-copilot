class OpsProcurementSavedViewsController < ApplicationController
  def create
    current_user.update!(ops_procurement_saved_filters: normalized_filters)
    redirect_to operations_procurement_path(normalized_filters), notice: "Procurement view saved as default."
  end

  def destroy
    current_user.update!(ops_procurement_saved_filters: {})
    redirect_to operations_procurement_path, notice: "Saved procurement view cleared."
  end

  private

  def normalized_filters
    params.permit(:program_id, :supplier, :commodity, :buyer, :part_number, :start_date, :end_date).to_h.compact_blank
  end
end
