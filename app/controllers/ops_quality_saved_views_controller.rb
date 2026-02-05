class OpsQualitySavedViewsController < ApplicationController
  def create
    current_user.update!(ops_quality_saved_filters: normalized_filters)
    redirect_to operations_quality_path(normalized_filters), notice: "Quality view saved as default."
  end

  def destroy
    current_user.update!(ops_quality_saved_filters: {})
    redirect_to operations_quality_path, notice: "Saved quality view cleared."
  end

  private

  def normalized_filters
    params.permit(:program_id, :part_number, :reason_code, :disposition, :start_date, :end_date).to_h.compact_blank
  end
end
