class CreateContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :contracts do |t|
      t.references :program, null: false, foreign_key: true
      t.string :contract_code
      t.integer :fiscal_year
      t.date :start_date
      t.date :end_date
      t.integer :planned_quantity
      t.decimal :sell_price_per_unit
      t.text :notes

      t.timestamps
    end
  end
end
