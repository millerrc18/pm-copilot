class CreateOpsImportsAndTables < ActiveRecord::Migration[8.0]
  def change
    create_table :ops_imports do |t|
      t.references :program, null: false, foreign_key: true
      t.references :imported_by, null: false, foreign_key: { to_table: :users }
      t.string :report_type, null: false
      t.string :source_filename
      t.string :checksum, null: false
      t.integer :rows_imported, null: false, default: 0
      t.integer :rows_rejected, null: false, default: 0
      t.string :status, null: false, default: "completed"
      t.datetime :imported_at
      t.json :notes, null: false, default: {}
      t.timestamps
    end

    add_index :ops_imports, [ :program_id, :report_type, :checksum ], unique: true

    create_table :ops_materials do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.string :part_number
      t.string :part_description
      t.string :supplier
      t.string :commodity
      t.string :buyer
      t.string :purchase_order
      t.date :order_date
      t.date :need_date
      t.date :receipt_date
      t.decimal :quantity_ordered, precision: 12, scale: 2
      t.decimal :quantity_received, precision: 12, scale: 2
      t.decimal :unit_cost, precision: 12, scale: 2
      t.decimal :extended_cost, precision: 12, scale: 2
      t.integer :lead_time_days
      t.timestamps
    end

    create_table :ops_shop_orders do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.string :order_number, null: false
      t.string :release_number
      t.string :status
      t.string :part_number
      t.string :part_description
      t.string :work_center
      t.date :planned_start
      t.date :planned_finish
      t.date :actual_start
      t.date :actual_finish
      t.date :due_date
      t.decimal :order_quantity, precision: 12, scale: 2
      t.decimal :completed_quantity, precision: 12, scale: 2
      t.decimal :remaining_quantity, precision: 12, scale: 2
      t.decimal :estimated_hours, precision: 12, scale: 2
      t.decimal :actual_hours, precision: 12, scale: 2
      t.timestamps
    end

    add_index :ops_shop_orders, [ :program_id, :order_number ]

    create_table :ops_shop_order_operations do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.string :order_number, null: false
      t.string :operation_number, null: false
      t.string :sequence
      t.string :status
      t.string :work_center
      t.date :scheduled_start
      t.date :scheduled_finish
      t.date :actual_start
      t.date :actual_finish
      t.decimal :setup_hours, precision: 12, scale: 2
      t.decimal :run_hours, precision: 12, scale: 2
      t.decimal :labor_hours, precision: 12, scale: 2
      t.decimal :queue_time, precision: 12, scale: 2
      t.timestamps
    end

    add_index :ops_shop_order_operations, [ :program_id, :order_number ]

    create_table :ops_historical_efficiencies do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.date :period_start
      t.date :period_end
      t.string :labor_category
      t.string :work_center
      t.decimal :planned_hours, precision: 12, scale: 2
      t.decimal :actual_hours, precision: 12, scale: 2
      t.decimal :variance_hours, precision: 12, scale: 2
      t.decimal :efficiency_percent, precision: 6, scale: 2
      t.timestamps
    end

    create_table :ops_scrap_records do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.date :scrap_date
      t.string :part_number
      t.string :part_description
      t.string :reason_code
      t.string :shop_order_number
      t.decimal :scrap_quantity, precision: 12, scale: 2
      t.decimal :scrap_cost, precision: 12, scale: 2
      t.timestamps
    end

    create_table :ops_mrb_part_details do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.string :mrb_number, null: false
      t.string :line_number
      t.string :status
      t.string :disposition
      t.string :part_number
      t.string :part_description
      t.string :supplier
      t.date :created_date
      t.date :closed_date
      t.decimal :quantity, precision: 12, scale: 2
      t.decimal :unit_cost, precision: 12, scale: 2
      t.decimal :extended_cost, precision: 12, scale: 2
      t.timestamps
    end

    add_index :ops_mrb_part_details, [ :program_id, :mrb_number ]

    create_table :ops_mrb_dispo_lines do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.string :mrb_number, null: false
      t.string :line_number
      t.string :disposition
      t.string :responsible
      t.date :disposition_date
      t.decimal :disposition_quantity, precision: 12, scale: 2
      t.decimal :disposition_cost, precision: 12, scale: 2
      t.timestamps
    end

    add_index :ops_mrb_dispo_lines, [ :program_id, :mrb_number ]

    create_table :ops_bom_components do |t|
      t.references :program, null: false, foreign_key: true
      t.references :ops_import, null: false, foreign_key: true
      t.integer :source_row_number
      t.string :parent_part_number, null: false
      t.string :component_part_number, null: false
      t.string :component_description
      t.string :unit
      t.integer :level
      t.decimal :quantity_per, precision: 12, scale: 4
      t.date :effective_from
      t.date :effective_to
      t.timestamps
    end

    add_index :ops_bom_components, [ :program_id, :parent_part_number ]
  end
end
