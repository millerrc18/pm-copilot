class AddCostHubSavedFiltersToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :cost_hub_saved_filters, :json, default: {}, null: false
  end
end
