# == Schema Information
#
# Table name: ops_historical_efficiencies
#
#  id                 :bigint           not null, primary key
#  actual_hours       :decimal(12, 2)
#  efficiency_percent :decimal(6, 2)
#  labor_category     :string
#  period_end         :date
#  period_start       :date
#  planned_hours      :decimal(12, 2)
#  source_row_number  :integer
#  variance_hours     :decimal(12, 2)
#  work_center        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ops_import_id      :bigint           not null
#  program_id         :bigint           not null
#
class OpsHistoricalEfficiency < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :program_id, :ops_import_id, presence: true
end
