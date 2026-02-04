class PlanItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan_item, only: [ :update, :destroy ]

  def create
    @plan_item = PlanItem.new(plan_item_params)
    assign_program_and_contract(@plan_item)
    @plan_item.owner = resolve_owner

    if @plan_item.save
      redirect_back fallback_location: planning_hub_path(program_id: @plan_item.program_id),
                    notice: "Plan item created."
    else
      redirect_back fallback_location: planning_hub_path(program_id: @plan_item.program_id),
                    alert: @plan_item.errors.full_messages.to_sentence
    end
  end

  def update
    @plan_item.assign_attributes(plan_item_params)
    assign_program_and_contract(@plan_item)
    @plan_item.owner = resolve_owner

    if @plan_item.save
      redirect_back fallback_location: planning_hub_path(program_id: @plan_item.program_id),
                    notice: "Plan item updated."
    else
      redirect_back fallback_location: planning_hub_path(program_id: @plan_item.program_id),
                    alert: @plan_item.errors.full_messages.to_sentence
    end
  end

  def destroy
    program_id = @plan_item.program_id
    @plan_item.destroy
    redirect_back fallback_location: planning_hub_path(program_id: program_id),
                  notice: "Plan item deleted."
  end

  private

  def set_plan_item
    @plan_item = PlanItem.joins(:program).where(programs: { user_id: current_user.id }).find(params[:id])
  end

  def plan_item_params
    params.require(:plan_item).permit(
      :title,
      :description,
      :item_type,
      :status,
      :start_on,
      :due_on,
      :percent_complete,
      :sort_order,
      :program_id,
      :contract_id,
      :owner_id
    )
  end

  def assign_program_and_contract(plan_item)
    program = current_user.programs.find_by(id: plan_item_params[:program_id])
    plan_item.errors.add(:program_id, "is invalid.") unless program
    plan_item.program = program

    if plan_item_params[:contract_id].present?
      contract = program&.contracts&.find_by(id: plan_item_params[:contract_id])
      plan_item.contract = contract
    else
      plan_item.contract = nil
    end
  end

  def resolve_owner
    return nil if plan_item_params[:owner_id].blank?

    User.find_by(id: plan_item_params[:owner_id])
  end
end
