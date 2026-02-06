class ContractPeriodsController < ApplicationController
  before_action :set_contract
  before_action :set_period, only: %i[edit update destroy]

  def new
    @contract_period = @contract.contract_periods.build
  end

  def create
    @contract_period = @contract.contract_periods.build(period_params)
    respond_to do |format|
      if @contract_period.save
        format.html { redirect_to contract_path(@contract), notice: "Period record was successfully created." }
        format.turbo_stream { redirect_to contract_path(@contract), notice: "Period record was successfully created." }
      else
        flash.now[:alert] = "Period record could not be saved."
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash"),
            turbo_stream.replace(
              view_context.dom_id(@contract_period, :form),
              partial: "contract_periods/form",
              locals: { period: @contract_period }
            )
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @period.update(period_params)
        format.html { redirect_to contract_path(@contract), notice: "Period record was successfully updated." }
        format.turbo_stream { redirect_to contract_path(@contract), notice: "Period record was successfully updated." }
      else
        flash.now[:alert] = "Period record could not be saved."
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash"),
            turbo_stream.replace(
              view_context.dom_id(@period, :form),
              partial: "contract_periods/form",
              locals: { period: @period }
            )
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @period.destroy
    redirect_to contract_path(@contract), notice: "Period record was successfully destroyed."
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
end
