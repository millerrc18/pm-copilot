class CreatePlanItems < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_items do |t|
      t.references :program, null: false, foreign_key: true
      t.references :contract, foreign_key: true
      t.references :owner, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.string :item_type, null: false
      t.string :status, null: false, default: "planned"
      t.date :start_on
      t.date :due_on
      t.integer :percent_complete
      t.integer :sort_order

      t.timestamps
    end

    add_index :plan_items, :item_type
    add_index :plan_items, :status
  end
end
