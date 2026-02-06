class Operations::EfficiencyController < Operations::BaseController
  def index
    @programs = current_user.programs.order(:name)
    @saved_filters = saved_filters_for(:ops_efficiency_saved_filters)
    filters = filter_params
    @using_saved_filters = false

    if filters.compact_blank.empty? && @saved_filters.present?
      filters = @saved_filters
      @using_saved_filters = true
    end

    @program = current_user.programs.find_by(id: filters["program_id"])
    @labor_category = filters["labor_category"]
    @work_center = filters["work_center"]

    @start_date, @end_date = resolve_dates(filters)

    scope = OpsHistoricalEfficiency.all
    scope = scope.where(program: @program) if @program
    scope = scope.where(period_start: @start_date..@end_date) if @start_date && @end_date
    scope = scope.where("labor_category ILIKE ?", "%#{@labor_category}%") if @labor_category.present?
    scope = scope.where("work_center ILIKE ?", "%#{@work_center}%") if @work_center.present?

    @entries = scope.order(period_start: :asc)
    @operations_empty = @entries.none?

    planned = @entries.sum(:planned_hours).to_d
    actual = @entries.sum(:actual_hours).to_d
    variance = actual - planned
    variance_percent = planned.zero? ? nil : ((variance / planned) * 100).round(2)

    @summary = {
      planned: planned,
      actual: actual,
      variance: variance,
      variance_percent: variance_percent
    }

    @trend_labels = @entries.map { |entry| entry.period_start&.strftime("%Y-%m-%d") || "Unknown" }
    @planned_values = @entries.map { |entry| entry.planned_hours.to_d }
    @actual_values = @entries.map { |entry| entry.actual_hours.to_d }
    @variance_values = @entries.map { |entry| entry.variance_hours.to_d }
  end

  private

  def filter_params
    params.permit(:program_id, :labor_category, :work_center, :start_date, :end_date).to_h
  end

  def resolve_dates(filters)
    start_date = parsed_date(filters["start_date"])
    end_date = parsed_date(filters["end_date"])

    if start_date.nil? || end_date.nil?
      latest = OpsHistoricalEfficiency.where(program_id: filters["program_id"]).maximum(:period_start) || Date.current
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
end
