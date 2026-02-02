class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @user = current_user
    @stats = profile_stats(@user)
  end

  def update
    @user = current_user
    @stats = profile_stats(@user)

    if @user.update(user_params)
      redirect_to profile_path, notice: "Avatar updated."
    else
      flash.now[:alert] = "Unable to update avatar."
      render :profile, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:avatar)
  end

  def profile_stats(user)
    programs_count = user.programs.count
    contracts_count = Contract.joins(:program).where(programs: { user_id: user.id }).count
    cost_entries = CostEntry.joins(:program).where(programs: { user_id: user.id })
    total_cost = cost_entries.sum(<<~SQL.squish)
      COALESCE(hours_bam, 0) * COALESCE(rate_bam, 0) +
      COALESCE(hours_eng, 0) * COALESCE(rate_eng, 0) +
      COALESCE(hours_mfg_salary, 0) * COALESCE(rate_mfg_salary, 0) +
      COALESCE(hours_mfg_hourly, 0) * COALESCE(rate_mfg_hourly, 0) +
      COALESCE(hours_touch, 0) * COALESCE(rate_touch, 0) +
      COALESCE(material_cost, 0) +
      COALESCE(other_costs, 0)
    SQL

    {
      programs_count: programs_count,
      contracts_count: contracts_count,
      cost_entries_count: cost_entries.count,
      total_cost: total_cost
    }
  end
end
