class OpsBomSavedViewsController < ApplicationController
  def create
    current_user.update!(ops_bom_saved_filters: normalized_filters)
    redirect_to operations_bom_path(normalized_filters), notice: "BOM view saved as default."
  end

  def destroy
    current_user.update!(ops_bom_saved_filters: {})
    redirect_to operations_bom_path, notice: "Saved BOM view cleared."
  end

  private

  def normalized_filters
    params.permit(:program_id, :parent_part_number, :component_part_number, :view).to_h.compact_blank
  end
end
