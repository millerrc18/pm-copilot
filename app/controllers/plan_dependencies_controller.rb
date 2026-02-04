class PlanDependenciesController < ApplicationController
  before_action :authenticate_user!

  def create
    dependency = PlanDependency.new(plan_dependency_params)
    dependency.predecessor = scoped_plan_item(plan_dependency_params[:predecessor_id])
    dependency.successor = scoped_plan_item(plan_dependency_params[:successor_id])

    if dependency.predecessor.nil? || dependency.successor.nil?
      redirect_back fallback_location: planning_hub_path, alert: "Select valid plan items."
      return
    end

    if dependency.predecessor.program_id != dependency.successor.program_id
      redirect_back fallback_location: planning_hub_path(program_id: dependency.predecessor.program_id),
                    alert: "Dependencies must be within the same program."
      return
    end

    if dependency.save
      redirect_back fallback_location: planning_hub_path(program_id: dependency.predecessor.program_id),
                    notice: "Dependency added."
    else
      redirect_back fallback_location: planning_hub_path(program_id: dependency.predecessor.program_id),
                    alert: dependency.errors.full_messages.to_sentence
    end
  end

  def destroy
    dependency = PlanDependency.joins(predecessor: :program)
      .where(programs: { user_id: current_user.id })
      .find(params[:id])
    program_id = dependency.predecessor.program_id
    dependency.destroy
    redirect_back fallback_location: planning_hub_path(program_id: program_id), notice: "Dependency removed."
  end

  private

  def plan_dependency_params
    params.require(:plan_dependency).permit(:predecessor_id, :successor_id, :dependency_type)
  end

  def scoped_plan_item(id)
    return nil if id.blank?

    PlanItem.joins(:program).where(programs: { user_id: current_user.id }).find_by(id: id)
  end
end
