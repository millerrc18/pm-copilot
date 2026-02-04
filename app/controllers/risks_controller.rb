class RisksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_risk, only: [ :edit, :update, :destroy ]
  before_action :set_scopes, only: [ :index, :new, :create, :edit, :update ]
  before_action :set_filters, only: [ :index ]

  def index
    return if @selected_program.blank?

    @risks = Risk.for_user(current_user).where(program_id: @selected_program.id)
    filtered_scope = apply_filters(@risks)
    @summary = RiskSummary.new(filtered_scope).call
    @risks = filtered_scope.order(due_date: :asc, created_at: :desc)

    capture_snapshot!
    build_chart_data
    build_heatmap_data
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

  def set_filters
    @filters = params.permit(:program_id, :contract_id, :risk_type, :status, :owner, :owner_scope, :query, :start_date, :end_date).to_h
    @filters = apply_saved_filters(@filters)
    @selected_program = resolve_program
    @filters["program_id"] ||= @selected_program&.id&.to_s
    @contracts = Contract.where(program_id: @selected_program&.id).order(:contract_code)
    @start_date = parsed_date(@filters["start_date"])
    @end_date = parsed_date(@filters["end_date"])
    @chart_start_date = @start_date || 30.days.ago.to_date
    @chart_end_date = @end_date || Date.current
  end

  def assign_scope(risk)
    program_id = risk_params[:program_id].presence
    contract_id = risk_params[:contract_id].presence

    risk.program = nil
    risk.contract = nil

    program = nil
    if program_id
      program = current_user.programs.find_by(id: program_id)
      unless program
        risk.errors.add(:base, "Select a valid program.")
        return
      end
    end

    contract = nil
    if contract_id
      contract = Contract.joins(:program)
        .where(programs: { user_id: current_user.id })
        .find_by(id: contract_id)
      unless contract
        risk.errors.add(:base, "Select a valid contract.")
        return
      end
    end

    if program && contract && contract.program_id != program.id
      risk.errors.add(:base, "Contract does not belong to the selected program.")
      return
    end

    risk.program = program || contract&.program
    risk.contract = contract

    return if risk.program

    risk.errors.add(:base, "Select a program or contract.")
  end

  def apply_filters(scope)
    scoped = scope
    scoped = scoped.where(contract_id: @filters["contract_id"]) if @filters["contract_id"].present?
    scoped = scoped.where(risk_type: @filters["risk_type"]) if @filters["risk_type"].present?
    scoped = scoped.where(status: @filters["status"]) if @filters["status"].present?
    scoped = scoped.where("owner ILIKE ?", "%#{@filters['owner']}%") if @filters["owner"].present?
    if @filters["start_date"].present? || @filters["end_date"].present?
      start_date = @start_date || 1.year.ago.to_date
      end_date = @end_date || 1.year.from_now.to_date
      scoped = scoped.where(due_date: start_date..end_date)
    end

    if @filters["owner_scope"] == "mine"
      scoped = scoped.where("owner ILIKE ?", "%#{owner_scope_value}%")
    end

    if @filters["query"].present?
      query = "%#{@filters['query']}%"
      scoped = scoped.where("title ILIKE :query OR description ILIKE :query OR owner ILIKE :query", query: query)
    end
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

  def apply_saved_filters(filters)
    return filters if filters.values.any?(&:present?)
    return filters if current_user.risk_saved_filters.blank?

    @using_saved_filters = true
    current_user.risk_saved_filters
  end

  def resolve_program
    program_id = @filters["program_id"].presence
    program = @programs.find_by(id: program_id)
    program || @programs.first
  end

  def parsed_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end

  def owner_scope_value
    owner_name = [ current_user.first_name, current_user.last_name ].map(&:presence).compact.join(" ").strip
    owner_name.presence || current_user.email
  end

  def capture_snapshot!
    return if @selected_program.blank?

    RiskExposureSnapshot.capture_for_program(@selected_program)
  end

  def build_chart_data
    snapshots = RiskExposureSnapshot.where(program_id: @selected_program.id, snapshot_on: @chart_start_date..@chart_end_date).order(:snapshot_on)
    if snapshots.empty?
      snapshots = RiskExposureSnapshot.where(program_id: @selected_program.id, snapshot_on: @chart_start_date..@chart_end_date).order(:snapshot_on)
    end

    labels = snapshots.map { |snapshot| snapshot.snapshot_on.strftime("%b %-d") }
    risk_totals = snapshots.map(&:risk_total)
    opportunity_totals = snapshots.map(&:opportunity_total)
    net_totals = risk_totals.zip(opportunity_totals).map { |risk, opp| opp.to_i - risk.to_i }

    @burndown_labels = labels
    @burndown_datasets = [
      {
        label: "Risk exposure",
        data: risk_totals,
        borderColor: "rgba(248, 113, 113, 0.9)",
        backgroundColor: "rgba(248, 113, 113, 0.2)",
        fill: true,
        tension: 0.3
      },
      {
        label: "Target",
        data: target_burndown_series(risk_totals),
        borderColor: "rgba(148, 163, 184, 0.8)",
        backgroundColor: "rgba(148, 163, 184, 0.2)",
        borderDash: [ 4, 4 ],
        fill: false,
        tension: 0.3
      }
    ]

    @opportunity_labels = labels
    @opportunity_datasets = [
      {
        label: "Opportunity exposure",
        data: opportunity_totals,
        borderColor: "rgba(34, 197, 94, 0.9)",
        backgroundColor: "rgba(34, 197, 94, 0.2)",
        fill: true,
        tension: 0.3
      }
    ]

    @net_labels = labels
    @net_datasets = [
      {
        label: "Net exposure",
        data: net_totals,
        borderColor: "rgba(56, 189, 248, 0.9)",
        backgroundColor: "rgba(56, 189, 248, 0.2)",
        fill: true,
        tension: 0.3
      }
    ]
  end

  def target_burndown_series(risk_totals)
    return [] if risk_totals.blank?

    start = risk_totals.first.to_f
    return [ start ] if risk_totals.length == 1

    step = start / (risk_totals.length - 1)
    risk_totals.length.times.map { |index| (start - (step * index)).round(2) }
  end

  def build_heatmap_data
    base_scope = Risk.for_user(current_user).where(program_id: @selected_program.id)
    base_scope = apply_filters(base_scope.except(:order))
    @risk_heatmap = build_heatmap_matrix(base_scope.where(risk_type: "risk"))
    @opportunity_heatmap = build_heatmap_matrix(base_scope.where(risk_type: "opportunity"))
  end

  def build_heatmap_matrix(scope)
    matrix = Array.new(5) { Array.new(5, 0) }
    scope.group(:probability, :impact).count.each do |(probability, impact), count|
      next if probability.blank? || impact.blank?

      matrix[impact.to_i - 1][probability.to_i - 1] = count
    end
    matrix
  end
end
