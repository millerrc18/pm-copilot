class Operations::ProductionController < Operations::BaseController
  def index
    @programs = current_user.programs.order(:name)
    @saved_filters = saved_filters_for(:ops_production_saved_filters)
    filters = filter_params
    @using_saved_filters = false

    if filters.compact_blank.empty? && @saved_filters.present?
      filters = @saved_filters
      @using_saved_filters = true
    end

    @tab = filters["tab"].presence || "orders"
    @program = current_user.programs.find_by(id: filters["program_id"])
    @status = filters["status"]
    @work_center = filters["work_center"]
    @part_number = filters["part_number"]

    @start_date, @end_date = resolve_dates(filters)

    orders_scope = OpsShopOrder.all
    orders_scope = orders_scope.where(program: @program) if @program
    orders_scope = orders_scope.where(due_date: @start_date..@end_date) if @start_date && @end_date
    orders_scope = orders_scope.where("status ILIKE ?", "%#{@status}%") if @status.present?
    orders_scope = orders_scope.where("work_center ILIKE ?", "%#{@work_center}%") if @work_center.present?
    orders_scope = orders_scope.where("part_number ILIKE ?", "%#{@part_number}%") if @part_number.present?

    @orders = orders_scope.order(due_date: :asc)
    @summary = production_summary(@orders)

    operations_scope = OpsShopOrderOperation.all
    operations_scope = operations_scope.where(program: @program) if @program
    operations_scope = operations_scope.where("status ILIKE ?", "%#{@status}%") if @status.present?
    operations_scope = operations_scope.where("work_center ILIKE ?", "%#{@work_center}%") if @work_center.present?
    operations_scope = operations_scope.where("order_number ILIKE ?", "%#{filters["order_number"]}%") if filters["order_number"].present?
    operations_scope = operations_scope.where(actual_start: @start_date..@end_date) if @start_date && @end_date

    @operations = operations_scope.order(actual_start: :asc)
    @operations_empty = @orders.none? && @operations.none?
  end

  private

  def filter_params
    params.permit(:program_id, :status, :work_center, :part_number, :order_number, :start_date, :end_date, :tab).to_h
  end

  def resolve_dates(filters)
    start_date = parsed_date(filters["start_date"])
    end_date = parsed_date(filters["end_date"])

    if start_date.nil? || end_date.nil?
      latest = OpsShopOrder.where(program_id: filters["program_id"]).maximum(:due_date) || Date.current
      [ latest - 90, latest ]
    else
      [ start_date, end_date ]
    end
  end

  def parsed_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end

  def production_summary(orders)
    late = orders.where("due_date < ?", Date.current).where.not(status: "closed").count
    in_progress = orders.where("status ILIKE ?", "%progress%").count

    {
      total_orders: orders.count,
      late_orders: late,
      in_progress: in_progress,
      due_soon: orders.where(due_date: Date.current..(Date.current + 7)).count
    }
  end
end
