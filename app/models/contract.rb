# == Schema Information
#
# Table name: contracts
#
#  id                  :bigint           not null, primary key
#  contract_code       :string
#  end_date            :date
#  fiscal_year         :integer
#  notes               :text
#  planned_quantity    :integer
#  sell_price_per_unit :decimal(, )
#  start_date          :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  program_id          :bigint           not null
#
# Indexes
#
#  index_contracts_on_program_id  (program_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
class Contract < ApplicationRecord
  belongs_to :program
  has_many :contract_periods, dependent: :destroy

  validates :contract_code, :start_date, :end_date, :sell_price_per_unit, presence: true

  # aggregated helpers
  def total_units_delivered
    contract_periods.sum(:units_delivered)
  end

  def total_cost
    contract_periods.sum(&:total_cost)
  end

  def total_revenue
    contract_periods.sum(&:revenue_total)
  end

  def average_cost_per_unit
    return 0 if total_units_delivered.zero?
    total_cost / total_units_delivered
  end

  def average_margin_per_unit
    return 0 if total_units_delivered.zero?
    (total_revenue - total_cost) / total_units_delivered
  end
end
