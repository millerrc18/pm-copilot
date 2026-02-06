class DeliveryMilestonesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contract, only: [:index, :new, :create], if: -> { params[:contract_id].present? }
  before_action :set_delivery_milestone, only: [:show, :edit, :update, :destroy]

  def index
    @milestones = if @contract
      @contract.delivery_milestones.order(:due_date)
    else
      DeliveryMilestone.joins(contract: :program)
        .where(programs: { user_id: current_user.id })
        .includes(contract: :program)
        .order("programs.name asc, contracts.contract_code asc, delivery_milestones.due_date asc")
    end
  end

  def show
    # Same idea: keep the route happy, but use the contract page as the UI
    redirect_to contract_path(@contract)
  end

  def new
    unless @contract
      @contracts = current_user.programs.includes(:contracts).flat_map(&:contracts)
      return render :new_select
    end

    @delivery_milestone = @contract.delivery_milestones.build
  end

  def create
    @delivery_milestone = @contract.delivery_milestones.build(delivery_milestone_params)

    respond_to do |format|
      if @delivery_milestone.save
        format.html { redirect_to contract_path(@contract), notice: "Milestone created." }
        format.turbo_stream { redirect_to contract_path(@contract), notice: "Milestone created." }
      else
        flash.now[:alert] = "Milestone could not be saved."
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash"),
            turbo_stream.replace(
              view_context.dom_id(@delivery_milestone, :form),
              partial: "delivery_milestones/form",
              locals: { delivery_milestone: @delivery_milestone }
            )
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @delivery_milestone.update(delivery_milestone_params)
        format.html { redirect_to(safe_return_to || contract_path(@contract), notice: "Milestone updated.") }
        format.turbo_stream { redirect_to(safe_return_to || contract_path(@contract), notice: "Milestone updated.") }
      else
        flash.now[:alert] = "Milestone could not be saved."
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash"),
            turbo_stream.replace(
              view_context.dom_id(@delivery_milestone, :form),
              partial: "delivery_milestones/form",
              locals: { delivery_milestone: @delivery_milestone }
            )
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @delivery_milestone.destroy
    redirect_back fallback_location: contract_path(@contract), notice: "Milestone deleted."
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

  def safe_return_to
    return unless params[:return_to].present?
    return unless params[:return_to] == planning_hub_path

    params[:return_to]
  end
end
