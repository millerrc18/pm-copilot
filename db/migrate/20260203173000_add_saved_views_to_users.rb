class AddSavedViewsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :risk_saved_filters, :json, default: {}, null: false
    add_column :users, :planning_hub_saved_filters, :json, default: {}, null: false
  end
end
