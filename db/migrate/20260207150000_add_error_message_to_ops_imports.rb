class AddErrorMessageToOpsImports < ActiveRecord::Migration[8.0]
  def up
    add_column :ops_imports, :error_message, :string
    change_column_default :ops_imports, :status, from: "completed", to: "queued"

    execute <<~SQL
      UPDATE ops_imports
      SET status = 'succeeded'
      WHERE status = 'completed'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE ops_imports
      SET status = 'completed'
      WHERE status = 'succeeded'
    SQL

    change_column_default :ops_imports, :status, from: "queued", to: "completed"
    remove_column :ops_imports, :error_message
  end
end
