class AddOperationsSavedFiltersToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ops_procurement_saved_filters, :json, default: {}, null: false
    add_column :users, :ops_production_saved_filters, :json, default: {}, null: false
    add_column :users, :ops_efficiency_saved_filters, :json, default: {}, null: false
    add_column :users, :ops_quality_saved_filters, :json, default: {}, null: false
    add_column :users, :ops_bom_saved_filters, :json, default: {}, null: false
  end
end
