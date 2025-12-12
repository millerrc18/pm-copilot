class AddMilestoneRefAndAmendmentsToDeliveryMilestones < ActiveRecord::Migration[8.0]
  def change
    add_column :delivery_milestones, :milestone_ref, :string
    add_column :delivery_milestones, :amendment_code, :string
    add_column :delivery_milestones, :amendment_effective_date, :date
    add_column :delivery_milestones, :amendment_notes, :text

    # Backfill existing rows so we can enforce NOT NULL on milestone_ref.
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE delivery_milestones
          SET milestone_ref = 'DUE-' || TO_CHAR(due_date, 'YYYYMMDD')
          WHERE milestone_ref IS NULL AND due_date IS NOT NULL;
        SQL
      end
    end

    # Remove the old unique index so due_date can change (amendments) and so milestones are keyed by milestone_ref.
    if index_exists?(:delivery_milestones, [:contract_id, :due_date], unique: true, name: "index_delivery_milestones_on_contract_id_and_due_date")
      remove_index :delivery_milestones, name: "index_delivery_milestones_on_contract_id_and_due_date"
    end

    change_column_null :delivery_milestones, :milestone_ref, false

    # New stable uniqueness
    add_index :delivery_milestones, [:contract_id, :milestone_ref],
      unique: true,
      name: "idx_dm_contract_ref"
  end
end
