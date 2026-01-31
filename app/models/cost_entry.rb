# == Schema Information
#
# Table name: cost_entries
#
#  id                :bigint           not null, primary key
#  hours_bam         :decimal(15, 2)
#  hours_eng         :decimal(15, 2)
#  hours_mfg_hourly  :decimal(15, 2)
#  hours_mfg_salary  :decimal(15, 2)
#  hours_touch       :decimal(15, 2)
#  import_id         :bigint
#  material_cost     :decimal(15, 2)
#  notes             :text
#  other_costs       :decimal(15, 2)
#  period_start_date :date             not null
#  period_type       :string           not null
#  rate_bam          :decimal(15, 2)
#  rate_eng          :decimal(15, 2)
#  rate_mfg_hourly   :decimal(15, 2)
#  rate_mfg_salary   :decimal(15, 2)
#  rate_touch        :decimal(15, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  program_id        :bigint
#
# Indexes
#
#  index_cost_entries_on_import_id         (import_id)
#  index_cost_entries_on_period_start_date (period_start_date)
#  index_cost_entries_on_program_id        (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
class CostEntry < ApplicationRecord
  belongs_to :program, optional: true

  validates :period_type, presence: true, inclusion: { in: %w[week month] }
  validates :period_start_date, presence: true

  validates :hours_bam, :hours_eng, :hours_mfg_salary, :hours_mfg_hourly, :hours_touch,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rate_bam, :rate_eng, :rate_mfg_salary, :rate_mfg_hourly, :rate_touch,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :material_cost, :other_costs,
            numericality: { greater_than_or_equal_to: 0 }

  def total_labor_hours
    hours_bam.to_d +
      hours_eng.to_d +
      hours_mfg_salary.to_d +
      hours_mfg_hourly.to_d +
      hours_touch.to_d
  end

  def total_labor_cost
    (hours_bam.to_d * rate_bam.to_d) +
      (hours_eng.to_d * rate_eng.to_d) +
      (hours_mfg_salary.to_d * rate_mfg_salary.to_d) +
      (hours_mfg_hourly.to_d * rate_mfg_hourly.to_d) +
      (hours_touch.to_d * rate_touch.to_d)
  end

  def total_cost
    total_labor_cost + material_cost.to_d + other_costs.to_d
  end
end
