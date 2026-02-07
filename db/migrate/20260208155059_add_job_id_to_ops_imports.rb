class AddJobIdToOpsImports < ActiveRecord::Migration[8.0]
  def change
    add_column :ops_imports, :job_id, :string, if_not_exists: true
  end
end
