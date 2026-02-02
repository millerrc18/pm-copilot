class UpdateUserThemePreferences < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE users
      SET theme = 'dark-blue'
      WHERE theme = 'dark' AND palette = 'blue'
    SQL

    execute <<~SQL.squish
      UPDATE users
      SET theme = 'dark-coral'
      WHERE theme = 'dark' AND palette <> 'blue'
    SQL

    change_column_default :users, :theme, from: "light", to: "dark-coral"
  end

  def down
    execute <<~SQL.squish
      UPDATE users
      SET theme = 'dark'
      WHERE theme IN ('dark-blue', 'dark-coral')
    SQL

    change_column_default :users, :theme, from: "dark-coral", to: "light"
  end
end
