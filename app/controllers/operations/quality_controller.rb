class Operations::QualityController < Operations::BaseController
  def index
    @programs = current_user.programs.order(:name)
    @saved_filters = saved_filters_for(:ops_quality_saved_filters)
    filters = filter_params
    @using_saved_filters = false

    if filters.compact_blank.empty? && @saved_filters.present?
      filters = @saved_filters
      @using_saved_filters = true
    end

    @program = current_user.programs.find_by(id: filters["program_id"])
    @part_number = filters["part_number"]
    @reason_code = filters["reason_code"]
    @disposition = filters["disposition"]

    @start_date, @end_date = resolve_dates(filters)

    scrap_scope = OpsScrapRecord.all
    scrap_scope = scrap_scope.where(program: @program) if @program
    scrap_scope = scrap_scope.where(scrap_date: @start_date..@end_date) if @start_date && @end_date
    scrap_scope = scrap_scope.where("part_number ILIKE ?", "%#{@part_number}%") if @part_number.present?
    scrap_scope = scrap_scope.where("reason_code ILIKE ?", "%#{@reason_code}%") if @reason_code.present?

    @scrap_records = scrap_scope.order(scrap_date: :desc)

    mrb_scope = OpsMrbPartDetail.all
    mrb_scope = mrb_scope.where(program: @program) if @program
    mrb_scope = mrb_scope.where(created_date: @start_date..@end_date) if @start_date && @end_date
    mrb_scope = mrb_scope.where("part_number ILIKE ?", "%#{@part_number}%") if @part_number.present?
    mrb_scope = mrb_scope.where("disposition ILIKE ?", "%#{@disposition}%") if @disposition.present?

    @mrb_records = mrb_scope.order(created_date: :desc)

    scrap_cost_total = @scrap_records.sum(:scrap_cost).to_d
    mrb_open_count = @mrb_records.where.not(status: "closed").count
    top_reason = @scrap_records.group(:reason_code).sum(:scrap_cost).max_by { |_k, v| v.to_d }&.first
    top_part = @scrap_records.group(:part_number).sum(:scrap_cost).max_by { |_k, v| v.to_d }&.first

    @summary = {
      scrap_cost_total: scrap_cost_total,
      mrb_open_count: mrb_open_count,
      top_reason: top_reason,
      top_part: top_part
    }

    reason_totals = @scrap_records.group(:reason_code).sum(:scrap_cost).sort_by { |_k, v| -v.to_d }
    @reason_labels, @reason_values = chart_series(reason_totals)

    time_totals = @scrap_records.group(:scrap_date).sum(:scrap_cost).sort_by { |k, _| k.to_s }
    @time_labels = time_totals.map { |date, _| date&.strftime("%Y-%m-%d") || "Unknown" }
    @time_values = time_totals.map { |_, value| value.to_d }
  end

  private

  def filter_params
    params.permit(:program_id, :part_number, :reason_code, :disposition, :start_date, :end_date).to_h
  end

  def resolve_dates(filters)
    start_date = parsed_date(filters["start_date"])
    end_date = parsed_date(filters["end_date"])

    if start_date.nil? || end_date.nil?
      latest = OpsScrapRecord.where(program_id: filters["program_id"]).maximum(:scrap_date) || Date.current
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

  def chart_series(totals)
    labels = []
    values = []
    totals.first(6).each do |label, value|
      labels << (label.presence || "Unknown")
      values << value.to_d
    end

    remaining = totals.drop(6).sum { |_label, value| value.to_d }
    if remaining.positive?
      labels << "Other"
      values << remaining
    end

    [ labels, values ]
  end
end
