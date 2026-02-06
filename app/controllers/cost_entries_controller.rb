class CostEntriesController < ApplicationController
  helper_method :sort_direction_for

  before_action :set_cost_entry, only: [ :edit, :update, :destroy, :duplicate ]
  before_action :set_programs, only: [ :new, :create, :edit, :update, :duplicate ]

  def index
    @programs = current_user.programs.order(:name)
    @saved_filters = normalized_saved_filters
    filter_params = params.permit(:start_date, :end_date, :program_id)
    @using_saved_filters = filter_params.values.all?(&:blank?) && @saved_filters.present?
    effective_filters = @using_saved_filters ? @saved_filters : filter_params.to_h

    @program = current_user.programs.find_by(id: effective_filters["program_id"]) if effective_filters["program_id"].present?

    @start_date = parsed_date(effective_filters["start_date"]) || Date.current.beginning_of_month
    @end_date = parsed_date(effective_filters["end_date"]) || Date.current

    if @start_date > @end_date
      flash.now[:alert] = "Start date cannot be after end date."
      @start_date = Date.current.beginning_of_month
      @end_date = Date.current
    end

    @sort = %w[date program].include?(params[:sort]) ? params[:sort] : "date"
    @direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    @filter_params = {
      start_date: @start_date,
      end_date: @end_date,
      program_id: @program&.id
    }.compact

    @entries = CostEntry.includes(:program)
                        .joins(:program)
                        .where(programs: { user_id: current_user.id })
                        .where(period_start_date: @start_date..@end_date)
    @entries = @entries.where(program_id: @program.id) if @program
    @entries = apply_sort(@entries).to_a

    @summary = CostEntrySummary.new(
      start_date: @start_date,
      end_date: @end_date,
      program: @program,
      programs_scope: current_user.programs
    ).call

    build_chart_data(@entries)
  end

  def new
    @cost_entry = CostEntry.new(program: selected_program)
  end

  def create
    @cost_entry = CostEntry.new(cost_entry_params.except(:program_id))
    assign_program

    respond_to do |format|
      if @cost_entry.save
        format.html { redirect_to cost_hub_path, notice: "Cost entry created." }
        format.turbo_stream { redirect_to cost_hub_path, notice: "Cost entry created." }
      else
        flash.now[:alert] = "Cost entry could not be saved."
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash"),
            turbo_stream.replace(
              view_context.dom_id(@cost_entry, :form),
              partial: "cost_entries/form",
              locals: { cost_entry: @cost_entry }
            )
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def edit; end

  def update
    @cost_entry.assign_attributes(cost_entry_params.except(:program_id))
    assign_program

    respond_to do |format|
      if @cost_entry.save
        format.html { redirect_to cost_hub_path, notice: "Cost entry updated." }
        format.turbo_stream { redirect_to cost_hub_path, notice: "Cost entry updated." }
      else
        flash.now[:alert] = "Cost entry could not be saved."
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash"),
            turbo_stream.replace(
              view_context.dom_id(@cost_entry, :form),
              partial: "cost_entries/form",
              locals: { cost_entry: @cost_entry }
            )
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def duplicate
    @cost_entry = @cost_entry.dup
    render :new
  end

  def destroy
    @cost_entry.destroy
    redirect_to cost_hub_path, notice: "Cost entry deleted."
  end

  private

  def set_cost_entry
    @cost_entry = CostEntry.find(params[:id])
  end

  def set_programs
    @programs = current_user.programs.order(:name)
  end

  def selected_program
    return nil if params[:program_id].blank?

    current_user.programs.find_by(id: params[:program_id])
  end

  def assign_program
    if cost_entry_params[:program_id].blank?
      @cost_entry.program = nil
      return
    end

    @cost_entry.program = current_user.programs.find_by(id: cost_entry_params[:program_id])
    return if @cost_entry.program

    @cost_entry.errors.add(:program, "is not available")
  end

  def cost_entry_params
    params.require(:cost_entry).permit(
      :period_type,
      :period_start_date,
      :hours_bam,
      :hours_eng,
      :hours_mfg_salary,
      :hours_mfg_hourly,
      :hours_touch,
      :rate_bam,
      :rate_eng,
      :rate_mfg_salary,
      :rate_mfg_hourly,
      :rate_touch,
      :material_cost,
      :other_costs,
      :notes,
      :program_id
    )
  end

  def parsed_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end

  def apply_sort(scope)
    return scope.order(period_start_date: @direction) if @sort == "date"

    scope.left_joins(:program)
         .order("programs.name #{@direction}, cost_entries.period_start_date #{@direction}")
  end

  def normalized_saved_filters
    raw = current_user.cost_hub_saved_filters || {}
    {
      "start_date" => raw["start_date"],
      "end_date" => raw["end_date"],
      "program_id" => raw["program_id"]
    }.compact_blank
  end

  def build_chart_data(entries)
    entries_by_date = entries.group_by(&:period_start_date)
    @chart_dates = entries_by_date.keys.sort
    @chart_labels = @chart_dates.map { |date| date.strftime("%b %-d") }

    @cost_line_datasets = cost_line_datasets(entries_by_date)
    @cost_stack_datasets = cost_stack_datasets(entries_by_date)
    @cost_composition_labels, @cost_composition_dataset = cost_composition_dataset(entries)
    @cost_per_unit_dataset = cost_per_unit_dataset(entries_by_date)
  end

  def cost_line_datasets(entries_by_date)
    period_styles = {
      "week" => { label: "Week", color: "#F87171" },
      "month" => { label: "Month", color: "#60A5FA" }
    }

    period_styles.map do |period_type, style|
      data_points = @chart_dates.map do |date|
        entries_by_date.fetch(date, []).select { |entry| entry.period_type == period_type }
                      .sum(&:total_cost).to_f
      end

      {
        label: style[:label],
        data: data_points,
        borderColor: style[:color],
        backgroundColor: style[:color],
        tension: 0.3,
        pointRadius: 3,
        pointHoverRadius: 4
      }
    end
  end

  def cost_stack_datasets(entries_by_date)
    series = [
      { key: :bam, label: "BAM", color: "#F87171" },
      { key: :eng, label: "ENG", color: "#FBBF24" },
      { key: :mfg_salary, label: "MFG Salary", color: "#34D399" },
      { key: :mfg_hourly, label: "MFG Hourly", color: "#60A5FA" },
      { key: :touch, label: "Touch", color: "#A78BFA" },
      { key: :material_cost, label: "Material", color: "#38BDF8" },
      { key: :other_costs, label: "Other", color: "#F472B6" }
    ]

    series.map do |series_item|
      data_points = @chart_dates.map do |date|
        entries = entries_by_date.fetch(date, [])
        sum_costs(entries, series_item[:key]).to_f
      end

      {
        label: series_item[:label],
        data: data_points,
        backgroundColor: series_item[:color],
        borderColor: series_item[:color]
      }
    end
  end

  def cost_composition_dataset(entries)
    series = [
      { key: :bam, label: "BAM", color: "#F87171" },
      { key: :eng, label: "ENG", color: "#FBBF24" },
      { key: :mfg_salary, label: "MFG Salary", color: "#34D399" },
      { key: :mfg_hourly, label: "MFG Hourly", color: "#60A5FA" },
      { key: :touch, label: "Touch", color: "#A78BFA" },
      { key: :material_cost, label: "Material", color: "#38BDF8" },
      { key: :other_costs, label: "Other", color: "#F472B6" }
    ]

    labels = series.map { |item| item[:label] }
    data_points = series.map { |item| sum_costs(entries, item[:key]).to_f }
    colors = series.map { |item| item[:color] }

    dataset = [
      {
        label: "Total cost",
        data: data_points,
        backgroundColor: colors,
        borderColor: colors
      }
    ]

    [ labels, dataset ]
  end

  def cost_per_unit_dataset(entries_by_date)
    units_scope = DeliveryUnit.joins(contract: :program)
      .where(programs: { user_id: current_user.id })
      .where(ship_date: @start_date..@end_date)

    units_scope = units_scope.where(programs: { id: @program.id }) if @program
    units_by_date = units_scope.group_by(&:ship_date)

    data_points = @chart_dates.map do |date|
      total_cost = entries_by_date.fetch(date, []).sum(&:total_cost).to_d
      units = units_by_date.fetch(date, []).count
      units.zero? ? 0 : (total_cost / units).to_f
    end

    [
      {
        label: "Cost per unit",
        data: data_points,
        borderColor: "#34D399",
        backgroundColor: "#34D399",
        tension: 0.3,
        pointRadius: 3,
        pointHoverRadius: 4
      }
    ]
  end

  def sum_costs(entries, key)
    case key
    when :bam
      entries.sum { |entry| entry.hours_bam.to_d * entry.rate_bam.to_d }
    when :eng
      entries.sum { |entry| entry.hours_eng.to_d * entry.rate_eng.to_d }
    when :mfg_salary
      entries.sum { |entry| entry.hours_mfg_salary.to_d * entry.rate_mfg_salary.to_d }
    when :mfg_hourly
      entries.sum { |entry| entry.hours_mfg_hourly.to_d * entry.rate_mfg_hourly.to_d }
    when :touch
      entries.sum { |entry| entry.hours_touch.to_d * entry.rate_touch.to_d }
    when :material_cost
      entries.sum { |entry| entry.material_cost.to_d }
    when :other_costs
      entries.sum { |entry| entry.other_costs.to_d }
    else
      0.to_d
    end
  end

  def sort_direction_for(column)
    if @sort == column && @direction == "asc"
      "desc"
    else
      "asc"
    end
  end
end
