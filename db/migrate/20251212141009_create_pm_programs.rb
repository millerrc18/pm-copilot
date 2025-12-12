class CreatePmPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_programs do |t|
      t.string :name
      t.string :customer
      t.text :description

      t.timestamps
    end
  end
end
