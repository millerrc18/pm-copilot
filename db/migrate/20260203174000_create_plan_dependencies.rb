class CreatePlanDependencies < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_dependencies do |t|
      t.references :predecessor, null: false, foreign_key: { to_table: :plan_items }
      t.references :successor, null: false, foreign_key: { to_table: :plan_items }
      t.string :dependency_type, null: false, default: "blocks"

      t.timestamps
    end

    add_index :plan_dependencies, [ :predecessor_id, :successor_id ], unique: true,
              name: "index_plan_dependencies_on_predecessor_and_successor"
  end
end
