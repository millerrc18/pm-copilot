class AddThemePreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :theme, :string, null: false, default: "light"
    add_column :users, :palette, :string, null: false, default: "blue"
  end
end
