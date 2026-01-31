class ProgramsController < ApplicationController
  def index
    @programs = current_user.programs.order(:name)
    @portfolio_metrics = portfolio_metrics
  end

  def show
    @program = current_user.programs.find(params[:id])
    @dashboard = ProgramDashboard.new(@program).call
    @contracts = @program.contracts
  end

  def new
    @program = current_user.programs.new
  end

  def create
    @program = current_user.programs.new(program_params)
    if @program.save
      redirect_to @program, notice: 'Program was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @program = current_user.programs.find(params[:id])
  end

  def update
    @program = current_user.programs.find(params[:id])

    if @program.update(program_params)
      redirect_to @program, notice: "Program was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @program = current_user.programs.find(params[:id])
    @program.destroy
    redirect_to programs_url, notice: "Program was successfully destroyed."
  end

  private

  def program_params
    params.require(:program).permit(:name, :customer, :description)
  end

  def portfolio_metrics
    today = Date.current
    contracts = Contract.joins(:program)
      .where(programs: { user_id: current_user.id })
      .includes(:delivery_units)

    milestones = DeliveryMilestone.joins(contract: :program)
      .where(programs: { user_id: current_user.id })

    at_risk = contracts.count do |contract|
      contract.end_date.present? &&
        contract.end_date < today &&
        contract.planned_quantity.to_i > contract.delivery_units.count
    end

    total_milestones = milestones.count
    on_time = total_milestones.zero? ? 0 : milestones.where("due_date >= ?", today).count
    on_time_rate = total_milestones.zero? ? 0 : ((on_time.to_f / total_milestones) * 100).round

    {
      active_programs: @programs.count,
      contracts_at_risk: at_risk,
      on_time_delivery: on_time_rate
    }
  end
end
