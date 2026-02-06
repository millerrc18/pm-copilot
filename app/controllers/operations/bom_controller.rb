class Operations::BomController < Operations::BaseController
  def index
    @programs = current_user.programs.order(:name)
    @saved_filters = saved_filters_for(:ops_bom_saved_filters)
    filters = filter_params
    @using_saved_filters = false

    if filters.compact_blank.empty? && @saved_filters.present?
      filters = @saved_filters
      @using_saved_filters = true
    end

    @view = filters["view"].presence || "tree"
    @program = current_user.programs.find_by(id: filters["program_id"])
    @parent_part_number = filters["parent_part_number"]
    @component_part_number = filters["component_part_number"]

    scope = OpsBomComponent.all
    scope = scope.where(program: @program) if @program

    if @parent_part_number.present?
      scope = scope.where(parent_part_number: @parent_part_number)
    end

    @bom_components = scope.order(:level, :component_part_number)

    @flattened_components = scope.group(:component_part_number)
                                .select("component_part_number, MAX(component_description) AS component_description, SUM(quantity_per) AS total_quantity")
                                .order("total_quantity DESC")

    where_used_scope = OpsBomComponent.all
    where_used_scope = where_used_scope.where(program: @program) if @program
    where_used_scope = where_used_scope.where(component_part_number: @component_part_number) if @component_part_number.present?

    @where_used = where_used_scope.select(:parent_part_number, :component_part_number, :level).distinct.order(:parent_part_number)
    @operations_empty = @bom_components.none?
  end

  private

  def filter_params
    params.permit(:program_id, :parent_part_number, :component_part_number, :view).to_h
  end
end
