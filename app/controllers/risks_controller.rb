class RisksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_risk, only: [ :edit, :update, :destroy ]
  before_action :set_scopes, only: [ :index, :new, :create, :edit, :update ]

  def index
    @filters = params.permit(:program_id, :contract_id, :risk_type, :status, :owner)
    @risks = Risk.for_user(current_user)
    @risks = apply_filters(@risks)
    @risks = @risks.order(due_date: :asc, created_at: :desc)
    @summary = RiskSummary.new(@risks).call
  end

  def new
    @risk = Risk.new(risk_type: "risk", status: "open")
  end

  def create
    @risk = Risk.new(risk_params.except(:program_id, :contract_id))
    assign_scope(@risk)

    if @risk.save
      redirect_to risks_path, notice: "Risk item created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @risk.assign_attributes(risk_params.except(:program_id, :contract_id))
    assign_scope(@risk)

    if @risk.save
      redirect_to risks_path, notice: "Risk item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @risk.destroy
    redirect_to risks_path, notice: "Risk item deleted."
  end

  private

  def set_risk
    @risk = Risk.for_user(current_user).find(params[:id])
  end

  def set_scopes
    @programs = current_user.programs.order(:name)
    @contracts = Contract.joins(:program)
      .where(programs: { user_id: current_user.id })
      .order("programs.name asc, contracts.contract_code asc")
  end

  def assign_scope(risk)
    program_id = risk_params[:program_id].presence
    contract_id = risk_params[:contract_id].presence

    risk.program = nil
    risk.contract = nil

    if program_id && contract_id
      risk.errors.add(:base, "Select a program or a contract, not both.")
      return
    end

    if program_id
      risk.program = current_user.programs.find_by(id: program_id)
    elsif contract_id
      risk.contract = Contract.joins(:program)
        .where(programs: { user_id: current_user.id })
        .find_by(id: contract_id)
    end

    return if risk.program || risk.contract

    risk.errors.add(:base, "Select a valid program or contract.")
  end

  def apply_filters(scope)
    scoped = scope
    scoped = scoped.where(program_id: @filters[:program_id]) if @filters[:program_id].present?
    scoped = scoped.where(contract_id: @filters[:contract_id]) if @filters[:contract_id].present?
    scoped = scoped.where(risk_type: @filters[:risk_type]) if @filters[:risk_type].present?
    scoped = scoped.where(status: @filters[:status]) if @filters[:status].present?
    scoped = scoped.where("owner ILIKE ?", "%#{@filters[:owner]}%") if @filters[:owner].present?
    scoped
  end

  def risk_params
    params.require(:risk).permit(
      :title,
      :description,
      :risk_type,
      :probability,
      :impact,
      :status,
      :owner,
      :due_date,
      :program_id,
      :contract_id
    )
  end
end
