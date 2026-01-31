class CostEntriesController < ApplicationController
  helper_method :sort_direction_for

  def index
    @programs = current_user.programs.order(:name)
    @program = current_user.programs.find_by(id: params[:program_id]) if params[:program_id].present?

    @start_date = parsed_date(params[:start_date]) || Date.current.beginning_of_month
    @end_date = parsed_date(params[:end_date]) || Date.current

    if @start_date > @end_date
      flash.now[:alert] = "Start date cannot be after end date."
      @start_date = Date.current.beginning_of_month
      @end_date = Date.current
    end

    @sort = %w[date program].include?(params[:sort]) ? params[:sort] : "date"
    @direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"

    @entries = CostEntry.includes(:program)
                        .where(period_start_date: @start_date..@end_date)
    @entries = @entries.where(program_id: @program.id) if @program
    @entries = apply_sort(@entries)

    @summary = CostEntrySummary.new(
      start_date: @start_date,
      end_date: @end_date,
      program: @program
    ).call
  end

  private

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

  def sort_direction_for(column)
    if @sort == column && @direction == "asc"
      "desc"
    else
      "asc"
    end
  end
end
