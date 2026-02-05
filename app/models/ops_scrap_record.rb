# == Schema Information
#
# Table name: ops_scrap_records
#
#  id                :bigint           not null, primary key
#  part_description  :string
#  part_number       :string
#  reason_code       :string
#  scrap_cost        :decimal(12, 2)
#  scrap_date        :date
#  scrap_quantity    :decimal(12, 2)
#  shop_order_number :string
#  source_row_number :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ops_import_id     :bigint           not null
#  program_id        :bigint           not null
#
class OpsScrapRecord < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :program_id, :ops_import_id, presence: true
end
