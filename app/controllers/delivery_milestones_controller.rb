class DeliveryMilestonesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contract, only: [:index, :new, :create]
  before_action :set_delivery_milestone, only: [:show, :edit, :update, :destroy]

  def index
    # You already show milestones on contract show, so just send them there
    redirect_to contract_path(@contract)
  end

  def show
    # Same idea: keep the route happy, but use the contract page as the UI
    redirect_to contract_path(@contract)
  end

  def new
    @delivery_milestone = @contract.delivery_milestones.build
  end

  def create
    @delivery_milestone = @contract.delivery_milestones.build(delivery_milestone_params)

    if @delivery_milestone.save
      redirect_to contract_path(@contract), notice: "Milestone created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @delivery_milestone.update(delivery_milestone_params)
      redirect_to contract_path(@contract), notice: "Milestone updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @delivery_milestone.destroy
    redirect_to contract_path(@contract), notice: "Milestone deleted."
  end

  private

  def set_contract
    @contract = Contract.joins(:program)
      .where(programs: { user_id: current_user.id })
      .find(params[:contract_id])
  end

  def set_delivery_milestone
    @delivery_milestone = DeliveryMilestone.joins(contract: :program)
      .where(programs: { user_id: current_user.id })
      .find(params[:id])

    @contract = @delivery_milestone.contract
  end

  def delivery_milestone_params
    params.require(:delivery_milestone).permit(
      :milestone_ref,
      :due_date,
      :quantity_due,
      :notes,
      :amendment_code,
      :amendment_effective_date,
      :amendment_notes
    )
  end
end
