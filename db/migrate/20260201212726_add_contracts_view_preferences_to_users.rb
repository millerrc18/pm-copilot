class AddContractsViewPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :contracts_view, :string
    add_column :users, :contracts_view_year, :integer
  end
end
