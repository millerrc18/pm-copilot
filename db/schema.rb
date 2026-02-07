# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_07_150000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "contract_periods", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.date "period_start_date"
    t.string "period_type"
    t.integer "units_delivered"
    t.decimal "revenue_per_unit", precision: 15, scale: 2
    t.decimal "hours_bam", precision: 15, scale: 2
    t.decimal "hours_eng", precision: 15, scale: 2
    t.decimal "hours_mfg_soft", precision: 15, scale: 2
    t.decimal "hours_mfg_hard", precision: 15, scale: 2
    t.decimal "hours_touch", precision: 15, scale: 2
    t.decimal "rate_bam", precision: 15, scale: 2
    t.decimal "rate_eng", precision: 15, scale: 2
    t.decimal "rate_mfg_soft", precision: 15, scale: 2
    t.decimal "rate_mfg_hard", precision: 15, scale: 2
    t.decimal "rate_touch", precision: 15, scale: 2
    t.decimal "material_cost", precision: 15, scale: 2
    t.decimal "other_costs", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.index ["contract_id", "period_start_date", "period_type"], name: "idx_cp_contract_date_type", unique: true
    t.index ["contract_id"], name: "index_contract_periods_on_contract_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "program_id", null: false
    t.string "contract_code"
    t.integer "fiscal_year"
    t.date "start_date"
    t.date "end_date"
    t.integer "planned_quantity"
    t.decimal "sell_price_per_unit", precision: 15, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_code"], name: "index_contracts_on_contract_code", unique: true
    t.index ["program_id"], name: "index_contracts_on_program_id"
  end

  create_table "cost_entries", force: :cascade do |t|
    t.string "period_type", null: false
    t.date "period_start_date", null: false
    t.decimal "hours_bam", precision: 15, scale: 2
    t.decimal "hours_eng", precision: 15, scale: 2
    t.decimal "hours_mfg_salary", precision: 15, scale: 2
    t.decimal "hours_mfg_hourly", precision: 15, scale: 2
    t.decimal "hours_touch", precision: 15, scale: 2
    t.decimal "rate_bam", precision: 15, scale: 2
    t.decimal "rate_eng", precision: 15, scale: 2
    t.decimal "rate_mfg_salary", precision: 15, scale: 2
    t.decimal "rate_mfg_hourly", precision: 15, scale: 2
    t.decimal "rate_touch", precision: 15, scale: 2
    t.decimal "material_cost", precision: 15, scale: 2
    t.decimal "other_costs", precision: 15, scale: 2
    t.text "notes"
    t.bigint "program_id", null: false
    t.bigint "import_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_cost_entries_on_import_id"
    t.index ["period_start_date"], name: "index_cost_entries_on_period_start_date"
    t.index ["program_id"], name: "index_cost_entries_on_program_id"
  end

  create_table "cost_imports", force: :cascade do |t|
    t.bigint "program_id", null: false
    t.bigint "user_id", null: false
    t.string "source_filename"
    t.integer "entries_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_cost_imports_on_program_id"
    t.index ["user_id"], name: "index_cost_imports_on_user_id"
  end

  create_table "delivery_milestones", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.date "due_date"
    t.integer "quantity_due"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "milestone_ref", null: false
    t.string "amendment_code"
    t.date "amendment_effective_date"
    t.text "amendment_notes"
    t.index ["contract_id", "milestone_ref"], name: "idx_dm_contract_ref", unique: true
    t.index ["contract_id"], name: "index_delivery_milestones_on_contract_id"
  end

  create_table "delivery_units", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.string "unit_serial"
    t.date "ship_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id", "unit_serial"], name: "index_delivery_units_on_contract_id_and_unit_serial", unique: true
    t.index ["contract_id"], name: "index_delivery_units_on_contract_id"
  end

  create_table "ops_bom_components", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.string "parent_part_number", null: false
    t.string "component_part_number", null: false
    t.string "component_description"
    t.string "unit"
    t.integer "level"
    t.decimal "quantity_per", precision: 12, scale: 4
    t.date "effective_from"
    t.date "effective_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_bom_components_on_ops_import_id"
    t.index ["program_id", "parent_part_number"], name: "index_ops_bom_components_on_program_id_and_parent_part_number"
    t.index ["program_id"], name: "index_ops_bom_components_on_program_id"
  end

  create_table "ops_historical_efficiencies", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.date "period_start"
    t.date "period_end"
    t.string "labor_category"
    t.string "work_center"
    t.decimal "planned_hours", precision: 12, scale: 2
    t.decimal "actual_hours", precision: 12, scale: 2
    t.decimal "variance_hours", precision: 12, scale: 2
    t.decimal "efficiency_percent", precision: 6, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_historical_efficiencies_on_ops_import_id"
    t.index ["program_id"], name: "index_ops_historical_efficiencies_on_program_id"
  end

  create_table "ops_imports", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "imported_by_id", null: false
    t.string "report_type", null: false
    t.string "source_filename"
    t.string "checksum", null: false
    t.integer "rows_imported", default: 0, null: false
    t.integer "rows_rejected", default: 0, null: false
    t.string "status", default: "queued", null: false
    t.datetime "imported_at"
    t.json "notes", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_message"
    t.index ["imported_by_id"], name: "index_ops_imports_on_imported_by_id"
    t.index ["program_id", "report_type", "checksum"], name: "index_ops_imports_on_program_id_and_report_type_and_checksum", unique: true
    t.index ["program_id"], name: "index_ops_imports_on_program_id"
  end

  create_table "ops_materials", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.string "part_number"
    t.string "part_description"
    t.string "supplier"
    t.string "commodity"
    t.string "buyer"
    t.string "purchase_order"
    t.date "order_date"
    t.date "need_date"
    t.date "receipt_date"
    t.decimal "quantity_ordered", precision: 12, scale: 2
    t.decimal "quantity_received", precision: 12, scale: 2
    t.decimal "unit_cost", precision: 12, scale: 2
    t.decimal "extended_cost", precision: 12, scale: 2
    t.integer "lead_time_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_materials_on_ops_import_id"
    t.index ["program_id"], name: "index_ops_materials_on_program_id"
  end

  create_table "ops_mrb_dispo_lines", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.string "mrb_number", null: false
    t.string "line_number"
    t.string "disposition"
    t.string "responsible"
    t.date "disposition_date"
    t.decimal "disposition_quantity", precision: 12, scale: 2
    t.decimal "disposition_cost", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_mrb_dispo_lines_on_ops_import_id"
    t.index ["program_id", "mrb_number"], name: "index_ops_mrb_dispo_lines_on_program_id_and_mrb_number"
    t.index ["program_id"], name: "index_ops_mrb_dispo_lines_on_program_id"
  end

  create_table "ops_mrb_part_details", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.string "mrb_number", null: false
    t.string "line_number"
    t.string "status"
    t.string "disposition"
    t.string "part_number"
    t.string "part_description"
    t.string "supplier"
    t.date "created_date"
    t.date "closed_date"
    t.decimal "quantity", precision: 12, scale: 2
    t.decimal "unit_cost", precision: 12, scale: 2
    t.decimal "extended_cost", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_mrb_part_details_on_ops_import_id"
    t.index ["program_id", "mrb_number"], name: "index_ops_mrb_part_details_on_program_id_and_mrb_number"
    t.index ["program_id"], name: "index_ops_mrb_part_details_on_program_id"
  end

  create_table "ops_scrap_records", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.date "scrap_date"
    t.string "part_number"
    t.string "part_description"
    t.string "reason_code"
    t.string "shop_order_number"
    t.decimal "scrap_quantity", precision: 12, scale: 2
    t.decimal "scrap_cost", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_scrap_records_on_ops_import_id"
    t.index ["program_id"], name: "index_ops_scrap_records_on_program_id"
  end

  create_table "ops_shop_order_operations", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.string "order_number", null: false
    t.string "operation_number", null: false
    t.string "sequence"
    t.string "status"
    t.string "work_center"
    t.date "scheduled_start"
    t.date "scheduled_finish"
    t.date "actual_start"
    t.date "actual_finish"
    t.decimal "setup_hours", precision: 12, scale: 2
    t.decimal "run_hours", precision: 12, scale: 2
    t.decimal "labor_hours", precision: 12, scale: 2
    t.decimal "queue_time", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_shop_order_operations_on_ops_import_id"
    t.index ["program_id", "order_number"], name: "index_ops_shop_order_operations_on_program_id_and_order_number"
    t.index ["program_id"], name: "index_ops_shop_order_operations_on_program_id"
  end

  create_table "ops_shop_orders", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "ops_import_id", null: false
    t.integer "source_row_number"
    t.string "order_number", null: false
    t.string "release_number"
    t.string "status"
    t.string "part_number"
    t.string "part_description"
    t.string "work_center"
    t.date "planned_start"
    t.date "planned_finish"
    t.date "actual_start"
    t.date "actual_finish"
    t.date "due_date"
    t.decimal "order_quantity", precision: 12, scale: 2
    t.decimal "completed_quantity", precision: 12, scale: 2
    t.decimal "remaining_quantity", precision: 12, scale: 2
    t.decimal "estimated_hours", precision: 12, scale: 2
    t.decimal "actual_hours", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ops_import_id"], name: "index_ops_shop_orders_on_ops_import_id"
    t.index ["program_id", "order_number"], name: "index_ops_shop_orders_on_program_id_and_order_number"
    t.index ["program_id"], name: "index_ops_shop_orders_on_program_id"
  end

  create_table "plan_dependencies", force: :cascade do |t|
    t.integer "predecessor_id", null: false
    t.integer "successor_id", null: false
    t.string "dependency_type", default: "blocks", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["predecessor_id", "successor_id"], name: "index_plan_dependencies_on_predecessor_and_successor", unique: true
    t.index ["predecessor_id"], name: "index_plan_dependencies_on_predecessor_id"
    t.index ["successor_id"], name: "index_plan_dependencies_on_successor_id"
  end

  create_table "plan_items", force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "contract_id"
    t.integer "owner_id"
    t.string "title", null: false
    t.text "description"
    t.string "item_type", null: false
    t.string "status", default: "planned", null: false
    t.date "start_on"
    t.date "due_on"
    t.integer "percent_complete"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_plan_items_on_contract_id"
    t.index ["item_type"], name: "index_plan_items_on_item_type"
    t.index ["owner_id"], name: "index_plan_items_on_owner_id"
    t.index ["program_id"], name: "index_plan_items_on_program_id"
    t.index ["status"], name: "index_plan_items_on_status"
  end

  create_table "programs", force: :cascade do |t|
    t.string "name"
    t.string "customer"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_programs_on_user_id"
  end

  create_table "risk_exposure_snapshots", force: :cascade do |t|
    t.integer "program_id", null: false
    t.date "snapshot_on", null: false
    t.integer "risk_total", default: 0, null: false
    t.integer "opportunity_total", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id", "snapshot_on"], name: "index_risk_exposure_snapshots_on_program_id_and_snapshot_on", unique: true
    t.index ["program_id"], name: "index_risk_exposure_snapshots_on_program_id"
  end

  create_table "risks", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "risk_type", null: false
    t.integer "probability", default: 1, null: false
    t.integer "impact", default: 1, null: false
    t.integer "severity_score", default: 1, null: false
    t.string "status", default: "open", null: false
    t.string "owner"
    t.date "due_date"
    t.integer "program_id", null: false
    t.integer "contract_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "mitigation"
    t.index ["contract_id"], name: "index_risks_on_contract_id"
    t.index ["program_id"], name: "index_risks_on_program_id"
    t.index ["risk_type"], name: "index_risks_on_risk_type"
    t.index ["status"], name: "index_risks_on_status"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "theme", default: "dark-coral", null: false
    t.string "palette", default: "blue", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "job_title"
    t.string "company"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "cost_hub_saved_filters", default: {}, null: false
    t.string "contracts_view"
    t.integer "contracts_view_year"
    t.json "risk_saved_filters", default: {}, null: false
    t.json "planning_hub_saved_filters", default: {}, null: false
    t.json "ops_procurement_saved_filters", default: {}, null: false
    t.json "ops_production_saved_filters", default: {}, null: false
    t.json "ops_efficiency_saved_filters", default: {}, null: false
    t.json "ops_quality_saved_filters", default: {}, null: false
    t.json "ops_bom_saved_filters", default: {}, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contract_periods", "contracts"
  add_foreign_key "contracts", "programs"
  add_foreign_key "cost_entries", "cost_imports", column: "import_id"
  add_foreign_key "cost_entries", "programs"
  add_foreign_key "cost_imports", "programs"
  add_foreign_key "cost_imports", "users"
  add_foreign_key "delivery_milestones", "contracts"
  add_foreign_key "delivery_units", "contracts"
  add_foreign_key "ops_bom_components", "ops_imports"
  add_foreign_key "ops_bom_components", "programs"
  add_foreign_key "ops_historical_efficiencies", "ops_imports"
  add_foreign_key "ops_historical_efficiencies", "programs"
  add_foreign_key "ops_imports", "programs"
  add_foreign_key "ops_imports", "users", column: "imported_by_id"
  add_foreign_key "ops_materials", "ops_imports"
  add_foreign_key "ops_materials", "programs"
  add_foreign_key "ops_mrb_dispo_lines", "ops_imports"
  add_foreign_key "ops_mrb_dispo_lines", "programs"
  add_foreign_key "ops_mrb_part_details", "ops_imports"
  add_foreign_key "ops_mrb_part_details", "programs"
  add_foreign_key "ops_scrap_records", "ops_imports"
  add_foreign_key "ops_scrap_records", "programs"
  add_foreign_key "ops_shop_order_operations", "ops_imports"
  add_foreign_key "ops_shop_order_operations", "programs"
  add_foreign_key "ops_shop_orders", "ops_imports"
  add_foreign_key "ops_shop_orders", "programs"
  add_foreign_key "plan_dependencies", "plan_items", column: "predecessor_id"
  add_foreign_key "plan_dependencies", "plan_items", column: "successor_id"
  add_foreign_key "plan_items", "contracts"
  add_foreign_key "plan_items", "programs"
  add_foreign_key "plan_items", "users", column: "owner_id"
  add_foreign_key "programs", "users"
  add_foreign_key "risk_exposure_snapshots", "programs"
  add_foreign_key "risks", "contracts"
  add_foreign_key "risks", "programs"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
