# frozen_string_literal: true

class CreateCostEntries < ActiveRecord::Migration[8.0]
  def up
    create_table :cost_entries do |t|
      t.string :period_type, null: false
      t.date :period_start_date, null: false
      t.decimal :hours_bam, precision: 15, scale: 2
      t.decimal :hours_eng, precision: 15, scale: 2
      t.decimal :hours_mfg_salary, precision: 15, scale: 2
      t.decimal :hours_mfg_hourly, precision: 15, scale: 2
      t.decimal :hours_touch, precision: 15, scale: 2
      t.decimal :rate_bam, precision: 15, scale: 2
      t.decimal :rate_eng, precision: 15, scale: 2
      t.decimal :rate_mfg_salary, precision: 15, scale: 2
      t.decimal :rate_mfg_hourly, precision: 15, scale: 2
      t.decimal :rate_touch, precision: 15, scale: 2
      t.decimal :material_cost, precision: 15, scale: 2
      t.decimal :other_costs, precision: 15, scale: 2
      t.text :notes
      t.references :program, foreign_key: true
      t.bigint :import_id

      t.timestamps
    end

    add_index :cost_entries, :period_start_date
    add_index :cost_entries, :import_id

    execute <<~SQL
      INSERT INTO cost_entries (
        period_type,
        period_start_date,
        hours_bam,
        hours_eng,
        hours_mfg_salary,
        hours_mfg_hourly,
        hours_touch,
        rate_bam,
        rate_eng,
        rate_mfg_salary,
        rate_mfg_hourly,
        rate_touch,
        material_cost,
        other_costs,
        notes,
        program_id,
        created_at,
        updated_at
      )
      SELECT
        contract_periods.period_type,
        contract_periods.period_start_date,
        contract_periods.hours_bam,
        contract_periods.hours_eng,
        contract_periods.hours_mfg_soft,
        contract_periods.hours_mfg_hard,
        contract_periods.hours_touch,
        contract_periods.rate_bam,
        contract_periods.rate_eng,
        contract_periods.rate_mfg_soft,
        contract_periods.rate_mfg_hard,
        contract_periods.rate_touch,
        contract_periods.material_cost,
        contract_periods.other_costs,
        contract_periods.notes,
        contracts.program_id,
        contract_periods.created_at,
        contract_periods.updated_at
      FROM contract_periods
      INNER JOIN contracts ON contracts.id = contract_periods.contract_id
    SQL
  end

  def down
    drop_table :cost_entries
  end
end
