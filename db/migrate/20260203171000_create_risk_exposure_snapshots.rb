class CreateRiskExposureSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :risk_exposure_snapshots do |t|
      t.references :program, null: false, foreign_key: true
      t.date :snapshot_on, null: false
      t.integer :risk_total, null: false, default: 0
      t.integer :opportunity_total, null: false, default: 0

      t.timestamps
    end

    add_index :risk_exposure_snapshots, [ :program_id, :snapshot_on ], unique: true,
              name: "index_risk_exposure_snapshots_on_program_id_and_snapshot_on"
  end
end
