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
  has_many :delivery_milestones, dependent: :destroy
  has_many :delivery_units, dependent: :destroy

  validates :contract_code, :start_date, :end_date, :sell_price_per_unit, presence: true

  # aggregated helpers
  def units_delivered_to_date(as_of: Date.current)
    delivery_units.where.not(ship_date: nil)
                  .where("ship_date <= ?", as_of)
                  .count
  end

  def total_revenue
    contract_periods.sum { |p| p.revenue_total.to_d }
  end

  def total_units_delivered
    units_delivered_to_date
  end

  def revenue_to_date(as_of: Date.current)
    contract_periods
      .where("period_start_date <= ?", as_of)
      .sum { |p| p.revenue_total.to_d }
  end

  def cost_to_date
    contract_periods.sum(&:total_cost).to_d
  end

  def total_cost
    cost_to_date
  end

  def total_margin
    total_revenue - total_cost
  end

  def avg_cost_per_unit
    return 0.to_d if total_units_delivered.to_i == 0
    total_cost / total_units_delivered
  end

  def avg_margin_per_unit
    return 0.to_d if total_units_delivered.to_i == 0
    total_margin / total_units_delivered
  end


end
