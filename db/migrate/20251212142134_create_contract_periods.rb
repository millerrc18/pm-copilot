class CreateContractPeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :contract_periods do |t|
      t.references :contract, null: false, foreign_key: true
      t.date :period_start_date
      t.string :period_type
      t.integer :units_delivered
      t.decimal :revenue_per_unit
      t.decimal :hours_bam
      t.decimal :hours_eng
      t.decimal :hours_mfg_soft
      t.decimal :hours_mfg_hard
      t.decimal :hours_touch
      t.decimal :rate_bam
      t.decimal :rate_eng
      t.decimal :rate_mfg_soft
      t.decimal :rate_mfg_hard
      t.decimal :rate_touch
      t.decimal :material_cost
      t.decimal :other_costs

      t.timestamps
    end
  end
end
