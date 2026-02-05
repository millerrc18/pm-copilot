namespace :ops do
  namespace :schema do
    desc "Fail if Operations tables or user filter columns are missing"
    task check: :environment do
      connection = ActiveRecord::Base.connection

      required_tables = %w[
        ops_imports
        ops_materials
        ops_shop_orders
        ops_shop_order_operations
        ops_historical_efficiencies
        ops_scrap_records
        ops_mrb_part_details
        ops_mrb_dispo_lines
        ops_bom_components
      ]

      required_columns = %w[
        ops_procurement_saved_filters
        ops_production_saved_filters
        ops_efficiency_saved_filters
        ops_quality_saved_filters
        ops_bom_saved_filters
      ]

      missing_tables = required_tables.reject { |table| connection.data_source_exists?(table) }
      missing_columns = required_columns.reject { |column| User.column_names.include?(column) }

      if missing_tables.any? || missing_columns.any?
        warn "Operations schema check failed. Run bin/rails db:migrate."
        warn "Missing tables: #{missing_tables.join(", ")}" if missing_tables.any?
        warn "Missing columns: #{missing_columns.join(", ")}" if missing_columns.any?
        exit 1
      end

      puts "Operations schema check passed."
    end
  end
end
