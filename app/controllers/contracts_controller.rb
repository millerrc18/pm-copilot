class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program, only: [:index, :new, :create], if: -> { params[:program_id].present? }
  before_action :set_contract, only: [:show, :edit, :update, :destroy]

  def index
    base_scope = if @program
      @program.contracts
    else
      Contract.joins(:program)
        .where(programs: { user_id: current_user.id })
        .includes(:program)
    end

    @contracts_view = resolve_contracts_view
    @contracts_view_year = resolve_contracts_view_year(@contracts_view)
    persist_contracts_view_preference(@contracts_view, @contracts_view_year)

    @contracts = apply_contracts_view(base_scope, @contracts_view, @contracts_view_year)

    @contracts = if @program
      @contracts.order(fiscal_year: :desc, contract_code: :asc)
    else
      @contracts.order("programs.name asc, contracts.contract_code asc")
    end
  end

  def show
    @periods    = @contract.contract_periods.order(:period_start_date)
    @milestones = @contract.delivery_milestones.order(:due_date)
    @units      = @contract.delivery_units.order(:ship_date, :unit_serial)
    @risk_summary = RiskSummary.new(Risk.for_user(current_user).for_contract(@contract.id)).call
    build_chart_data
  end

  def new
    @contract = @program.contracts.build
  end

  def create
    @contract = @program.contracts.build(contract_params)
    if @contract.save
      redirect_to @contract, notice: "Contract was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contract.update(contract_params)
      redirect_to(safe_return_to || @contract, notice: "Contract was successfully updated.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    program = @contract.program
    @contract.destroy
    redirect_to program_path(program), notice: "Contract was successfully destroyed."
  end

  private

  def set_program
    @program = current_user.programs.find(params[:program_id])
  end

  def set_contract
    @contract = Contract.joins(:program)
      .where(programs: { user_id: current_user.id })
      .find(params[:id])
  end

  def contract_params
    params.require(:contract).permit(
      :contract_code,
      :fiscal_year,
      :start_date,
      :end_date,
      :planned_quantity,
      :sell_price_per_unit,
      :notes
    )
  end

  def resolve_contracts_view
    raw_view = params[:view].presence || current_user.contracts_view_preference
    Contract::VIEW_OPTIONS.include?(raw_view) ? raw_view : "active_this_year"
  end

  def resolve_contracts_view_year(view)
    return Date.current.year + 1 if view == "active_next_year"
    return Date.current.year unless view == "active_in_year"

    raw_year = params[:year].presence || current_user.contracts_view_year
    raw_year.to_i.positive? ? raw_year.to_i : Date.current.year
  end

  def persist_contracts_view_preference(view, year)
    return if params[:view].blank? && params[:year].blank?

    preference_year = view == "active_in_year" ? year : nil
    current_user.update!(contracts_view: view, contracts_view_year: preference_year)
  end

  def apply_contracts_view(scope, view, year)
    case view
    when "active_this_year"
      scope.active_this_year
    when "active_next_year"
      scope.active_next_year
    when "active_in_year"
      scope.active_in_year(year)
    else
      scope
    end
  end

  def safe_return_to
    return unless params[:return_to].present?
    return unless params[:return_to] == planning_hub_path

    params[:return_to]
  end

  def build_chart_data
    periods_for_chart = @periods.select { |period| period.period_start_date.present? }
    @period_chart_labels = periods_for_chart.map { |period| period.period_start_date.strftime("%b %-d") }
    @units_chart_dataset = [
      {
        label: "Units delivered",
        data: periods_for_chart.map { |period| period.units_delivered.to_i },
        borderColor: "#F97316",
        backgroundColor: "#FDBA74",
        tension: 0.3,
        pointRadius: 3,
        pointHoverRadius: 4
      }
    ]
    @revenue_chart_dataset = [
      {
        label: "Revenue",
        data: periods_for_chart.map { |period| period.revenue_total.to_d.to_f },
        backgroundColor: "#38BDF8",
        borderColor: "#38BDF8"
      }
    ]
    @cost_revenue_dataset = [
      {
        label: "Revenue",
        data: periods_for_chart.map { |period| period.revenue_total.to_d.to_f },
        backgroundColor: "#38BDF8"
      },
      {
        label: "Cost",
        data: periods_for_chart.map { |period| period.total_cost.to_d.to_f },
        backgroundColor: "#F97316"
      }
    ]
  end
end
