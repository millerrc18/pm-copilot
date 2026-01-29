# == Schema Information
#
# Table name: contract_periods
#
#  id                :bigint           not null, primary key
#  hours_bam         :decimal(, )
#  hours_eng         :decimal(, )
#  hours_mfg_hard    :decimal(, )
#  hours_mfg_soft    :decimal(, )
#  hours_touch       :decimal(, )
#  material_cost     :decimal(, )
#  notes             :text
#  other_costs       :decimal(, )
#  period_start_date :date
#  period_type       :string
#  rate_bam          :decimal(, )
#  rate_eng          :decimal(, )
#  rate_mfg_hard     :decimal(, )
#  rate_mfg_soft     :decimal(, )
#  rate_touch        :decimal(, )
#  revenue_per_unit  :decimal(, )
#  units_delivered   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  contract_id       :bigint           not null
#
# Indexes
#
#  idx_cp_contract_date_type              (contract_id,period_start_date,period_type) UNIQUE
#  index_contract_periods_on_contract_id  (contract_id)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => contracts.id)
#
class ContractPeriod < ApplicationRecord
  belongs_to :contract

  validates :period_start_date, :period_type, :revenue_per_unit, presence: true

  # cost calculations
  def total_labor_cost
  (hours_bam.to_d      * rate_bam.to_d) +
  (hours_eng.to_d      * rate_eng.to_d) +
  (hours_mfg_soft.to_d * rate_mfg_soft.to_d) +
  (hours_mfg_hard.to_d * rate_mfg_hard.to_d) +
  (hours_touch.to_d    * rate_touch.to_d)
  end

  def total_cost
    total_labor_cost + material_cost.to_d + other_costs.to_d
  end


  def revenue_total
    units_delivered.to_i.to_d * revenue_per_unit.to_d
  end

  def cost_per_unit
    return 0 if units_delivered.to_i.zero?
    total_cost / units_delivered
  end

  def margin_per_unit
    revenue_per_unit - cost_per_unit
  end

  def total_margin
    revenue_total - total_cost
  end
end
