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
#  index_contract_periods_on_contract_id  (contract_id)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => contracts.id)
#
class ContractPeriod < ApplicationRecord
  belongs_to :contract

  validates :period_start_date, :period_type, presence: true

  # cost calculations
  def total_labor_cost
    (hours_bam * rate_bam) +
    (hours_eng * rate_eng) +
    (hours_mfg_soft * rate_mfg_soft) +
    (hours_mfg_hard * rate_mfg_hard) +
    (hours_touch * rate_touch)
  end

  def total_cost
    total_labor_cost + (material_cost || 0) + (other_costs || 0)
  end

  def revenue_total
    units_delivered.to_f * revenue_per_unit
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
