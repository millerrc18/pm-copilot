class ContractPeriodsController < ApplicationController
  before_action :set_contract
  before_action :set_period, only: %i[edit update destroy]

  def new
    @contract_period = @contract.contract_periods.build
  end

  def create
    @contract_period = @contract.contract_periods.build(period_params)
    if @contract_period.save
      redirect_to contract_path(@contract), notice: 'Period record was successfully created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @period.update(period_params)
      redirect_to contract_path(@contract), notice: 'Period record was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @period.destroy
    redirect_to contract_path(@contract), notice: 'Period record was successfully destroyed.'
  end

  private

  def set_contract
    @contract = Contract.joins(:program)
      .where(programs: { user_id: current_user.id })
      .find(params[:contract_id])

  end

  def set_period
    @period = @contract.contract_periods.find(params[:id])
  end

  def period_params
    params.require(:contract_period).permit(
      :period_start_date,
      :period_type,
      :units_delivered,
      :revenue_per_unit,
      :hours_bam,
      :rate_bam,
      :hours_eng,
      :rate_eng,
      :hours_mfg_soft,
      :rate_mfg_soft,
      :hours_mfg_hard,
      :rate_mfg_hard,
      :hours_touch,
      :rate_touch,
      :material_cost,
      :other_costs
    )
  end
  def contract_period_params
  params.require(:contract_period).permit(
    :period_start_date, :period_type,
    :hours_bam, :hours_eng, :hours_mfg_soft, :hours_mfg_hard, :hours_touch,
    :rate_bam, :rate_eng, :rate_mfg_soft, :rate_mfg_hard, :rate_touch,
    :material_cost, :other_costs,
    :notes
  )
end
end
