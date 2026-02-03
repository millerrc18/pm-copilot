class CreateRisks < ActiveRecord::Migration[7.1]
  def change
    create_table :risks do |t|
      t.string :title, null: false
      t.text :description
      t.string :risk_type, null: false
      t.integer :probability, null: false, default: 1
      t.integer :impact, null: false, default: 1
      t.integer :severity_score, null: false, default: 1
      t.string :status, null: false, default: "open"
      t.string :owner
      t.date :due_date
      t.references :program, foreign_key: true
      t.references :contract, foreign_key: true

      t.timestamps
    end

    add_index :risks, :risk_type
    add_index :risks, :status
  end
end
