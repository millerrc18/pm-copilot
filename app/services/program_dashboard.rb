# frozen_string_literal: true

require "bigdecimal/util"

class ProgramDashboard
  def initialize(program)
    @program = program
  end

  def call(as_of: Date.current)
    contracts = @program.contracts.includes(:contract_periods, :delivery_milestones, :delivery_units)

    contract_rows = contracts.map { |c| contract_rollup(c, as_of: as_of) }

    totals = {
      contracts_count: contracts.size,
      planned_units: contracts.sum { |c| c.planned_quantity.to_i },
      units_delivered: contract_rows.sum { |r| r[:units_delivered] },
      revenue_to_date: contract_rows.sum { |r| r[:revenue_to_date] },
      cost_to_date: contract_rows.sum { |r| r[:cost_to_date] },
      margin_to_date: 0.to_d,
      margin_pct_to_date: 0.to_d,
      avg_cost_per_unit: 0.to_d,
      otd_pct_to_date: 0.to_d,
      past_due_units: contract_rows.sum { |r| r[:past_due_units] },
      next_due_date: contract_rows.map { |r| r[:next_due_date] }.compact.min,
      next_due_units: contract_rows.sum { |r| r[:next_due_units] }
    }

    totals[:margin_to_date] = totals[:revenue_to_date] - totals[:cost_to_date]
    totals[:margin_pct_to_date] =
      totals[:revenue_to_date].zero? ? 0.to_d : (totals[:margin_to_date] / totals[:revenue_to_date])

    totals[:avg_cost_per_unit] =
      totals[:units_delivered].zero? ? 0.to_d : (totals[:cost_to_date] / totals[:units_delivered].to_d)

    due_to_date = contract_rows.sum { |r| r[:due_to_date_units] }
    on_time_to_date = contract_rows.sum { |r| r[:on_time_to_date_units] }
    totals[:otd_pct_to_date] = due_to_date.zero? ? 0.to_d : (on_time_to_date.to_d / due_to_date.to_d)

    { totals: totals, contracts: contract_rows }
  end

  private

  def d(v)
    return 0.to_d if v.nil? || v.to_s.strip.empty?
    v.to_d
  end

  def contract_rollup(contract, as_of:)
    # Costs are time-based, so keep using contract_periods, but filter through as_of
    periods = contract.contract_periods
                      .where("period_start_date <= ?", as_of)

    # Units delivered should come from delivery_units (unit-level shipments)
    units_delivered = contract.delivery_units
                              .where.not(ship_date: nil)
                              .where("ship_date <= ?", as_of)
                              .count

    # Revenue should come from contract periods to match Contract#total_revenue.
    revenue_to_date = periods.sum { |p| p.revenue_total.to_d }

    labor_cost = periods.sum do |p|
      d(p.hours_bam) * d(p.rate_bam) +
        d(p.hours_eng) * d(p.rate_eng) +
        d(p.hours_mfg_soft) * d(p.rate_mfg_soft) +
        d(p.hours_mfg_hard) * d(p.rate_mfg_hard) +
        d(p.hours_touch) * d(p.rate_touch)
    end

    material_cost = periods.sum { |p| d(p.material_cost) }
    other_costs   = periods.sum { |p| d(p.other_costs) }
    cost_to_date  = labor_cost + material_cost + other_costs

    margin_to_date = revenue_to_date - cost_to_date
    margin_pct_to_date = revenue_to_date.zero? ? 0.to_d : (margin_to_date / revenue_to_date)

    otd = otd_for_contract(contract, as_of: as_of)

    {
      id: contract.id,
      contract_code: contract.contract_code,
      fiscal_year: contract.fiscal_year,
      planned_units: contract.planned_quantity.to_i,

      units_delivered: units_delivered,
      revenue_to_date: revenue_to_date,
      cost_to_date: cost_to_date,
      margin_pct_to_date: margin_pct_to_date,

      due_to_date_units: otd[:due_to_date_units],
      on_time_to_date_units: otd[:on_time_to_date_units],
      past_due_units: otd[:past_due_units],
      next_due_date: otd[:next_due_date],
      next_due_units: otd[:next_due_units]
    }
  end


  # Allocates shipped units to milestones in due-date order (first due, first satisfied).
  def otd_for_contract(contract, as_of:)
    milestones = contract.delivery_milestones.order(:due_date).to_a
    shipped_dates = contract.delivery_units
      .where.not(ship_date: nil)
      .order(:ship_date)
      .pluck(:ship_date)

    due_to_date_units = milestones.select { |m| m.due_date && m.due_date <= as_of }.sum { |m| m.quantity_due.to_i }

    # Only shipments through as_of count toward to-date metrics
    shipped_through = shipped_dates.select { |d| d && d <= as_of }

    on_time_to_date_units = 0
    satisfied_to_date_units = 0

    milestones.select { |m| m.due_date && m.due_date <= as_of }.each do |m|
      qty = m.quantity_due.to_i
      qty.times do
        ship_date = shipped_through.shift
        break unless ship_date

        satisfied_to_date_units += 1
        on_time_to_date_units += 1 if ship_date <= m.due_date
      end
    end

    past_due_units = [due_to_date_units - satisfied_to_date_units, 0].max

    next_milestone = milestones.select { |m| m.due_date && m.due_date >= as_of }.min_by(&:due_date)

    {
      due_to_date_units: due_to_date_units,
      on_time_to_date_units: on_time_to_date_units,
      past_due_units: past_due_units,
      next_due_date: next_milestone&.due_date,
      next_due_units: next_milestone ? next_milestone.quantity_due.to_i : 0
    }
  end
end
