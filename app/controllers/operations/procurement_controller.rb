class Operations::ProcurementController < Operations::BaseController
  def index
    @programs = current_user.programs.order(:name)
    @saved_filters = saved_filters_for(:ops_procurement_saved_filters)
    filters = filter_params
    @using_saved_filters = false

    if filters.compact_blank.empty? && @saved_filters.present?
      filters = @saved_filters
      @using_saved_filters = true
    end

    @program = current_user.programs.find_by(id: filters["program_id"])
    @no_programs = @programs.empty?
    @program_missing = @program.nil?
    @supplier = filters["supplier"]
    @commodity = filters["commodity"]
    @buyer = filters["buyer"]
    @part_number = filters["part_number"]

    if @program_missing
      @start_date, @end_date = default_date_range
      initialize_procurement_empty_state
      return
    end

    @start_date, @end_date = resolve_dates(filters)

    scope = OpsMaterial.all
    scope = scope.where(program: @program) if @program
    scope = scope.where(receipt_date: @start_date..@end_date) if @start_date && @end_date
    scope = scope.where("supplier ILIKE ?", "%#{@supplier}%") if @supplier.present?
    scope = scope.where("commodity ILIKE ?", "%#{@commodity}%") if @commodity.present?
    scope = scope.where("buyer ILIKE ?", "%#{@buyer}%") if @buyer.present?
    scope = scope.where("part_number ILIKE ?", "%#{@part_number}%") if @part_number.present?

    @materials = scope.order(receipt_date: :desc)
    @no_materials = @materials.none?

    @summary = {
      total_spend: @materials.sum(:extended_cost).to_d,
      unique_parts: @materials.select(:part_number).distinct.count,
      top_supplier: top_group_value(@materials, :supplier),
      top_commodity: top_group_value(@materials, :commodity)
    }

    commodity_totals = @materials.group(:commodity).sum(:extended_cost).sort_by { |_k, v| -v.to_d }
    @commodity_labels, @commodity_totals = chart_series(commodity_totals)

    time_totals = @materials.group(:receipt_date).sum(:extended_cost).sort_by { |k, _| k.to_s }
    @time_labels = time_totals.map { |date, _| date&.strftime("%Y-%m-%d") || "Unknown" }
    @time_values = time_totals.map { |_, value| value.to_d }

    @parts = @materials.group(:part_number)
                       .select("part_number, SUM(extended_cost) AS total_spend, SUM(quantity_received) AS total_received")
                       .order("total_spend DESC")
                       .limit(25)
  end

  private

  def filter_params
    params.permit(:program_id, :supplier, :commodity, :buyer, :part_number, :start_date, :end_date).to_h
  end

  def resolve_dates(filters)
    start_date = parsed_date(filters["start_date"])
    end_date = parsed_date(filters["end_date"])

    if start_date.nil? || end_date.nil?
      latest = OpsMaterial.where(program_id: filters["program_id"]).maximum(:receipt_date) || Date.current
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

  def top_group_value(scope, column)
    scope.group(column).sum(:extended_cost).max_by { |_k, v| v.to_d }&.first
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
