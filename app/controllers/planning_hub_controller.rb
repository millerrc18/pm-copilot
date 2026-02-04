class PlanningHubController < ApplicationController
  before_action :authenticate_user!

  def index
    @programs = current_user.programs.order(:name)
    @filters = params.permit(:program_id, :item_type, :status, :owner_id, :view).to_h
    @filters = apply_saved_filters(@filters)
    @selected_program = resolve_program
    @filters["program_id"] ||= @selected_program&.id&.to_s
    @selected_view = @filters["view"].presence || "timeline"

    @plan_item = PlanItem.new(program_id: @selected_program&.id)
    @plan_items = PlanItem.includes(:program, :contract, :owner)
    @plan_items = @plan_items.where(program_id: @selected_program.id) if @selected_program
    @plan_items = apply_filters(@plan_items)
    @plan_items = @plan_items.order(:start_on, :due_on, :title)

    @dependencies = PlanDependency.includes(:predecessor, :successor)
    @dependencies = @dependencies.joins(predecessor: :program)
      .where(programs: { id: @selected_program.id }) if @selected_program
  end

  private

  def apply_saved_filters(filters)
    return filters if filters.values.any?(&:present?)
    return filters if current_user.planning_hub_saved_filters.blank?

    @using_saved_filters = true
    current_user.planning_hub_saved_filters
  end

  def resolve_program
    program_id = @filters["program_id"].presence
    program = @programs.find_by(id: program_id)
    program || @programs.first
  end

  def apply_filters(scope)
    scoped = scope
    scoped = scoped.where(item_type: @filters["item_type"]) if @filters["item_type"].present?
    scoped = scoped.where(status: @filters["status"]) if @filters["status"].present?
    scoped = scoped.where(owner_id: @filters["owner_id"]) if @filters["owner_id"].present?
    scoped
  end
end
