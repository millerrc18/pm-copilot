class AddMitigationToRisks < ActiveRecord::Migration[7.1]
  def change
    add_column :risks, :mitigation, :text unless column_exists?(:risks, :mitigation)
  end
end
