class DropDeliveryEvents < ActiveRecord::Migration[8.0]
  def change
    drop_table :delivery_events do |t|
      t.date :ship_date, null: false
      t.integer :quantity_shipped, null: false
      t.text :notes
      t.references :contract, null: false, foreign_key: true

      t.timestamps
    end
  end
end
