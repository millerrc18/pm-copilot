# frozen_string_literal: true

class CostEntrySummary
  def initialize(start_date:, end_date:, program: nil)
    @start_date = start_date
    @end_date = end_date
    @program = program
  end

  def call
    {
      total_cost: total_cost,
      total_units: total_units,
      average_cost_per_unit: average_cost_per_unit
    }
  end

  private

  def cost_entries
    scope = CostEntry.where(period_start_date: @start_date..@end_date)
    scope = scope.where(program_id: @program.id) if @program
    scope
  end

  def total_cost
    cost_entries.sum(&:total_cost).to_d
  end

  def total_units
    units = DeliveryUnit.where(ship_date: @start_date..@end_date)
    if @program
      units = units.joins(:contract).where(contracts: { program_id: @program.id })
    end
    units.count
  end

  def average_cost_per_unit
    return 0.to_d if total_units.zero?

    total_cost / total_units.to_d
  end
end
