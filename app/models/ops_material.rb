# == Schema Information
#
# Table name: ops_materials
#
#  id                :bigint           not null, primary key
#  buyer             :string
#  commodity         :string
#  extended_cost     :decimal(12, 2)
#  lead_time_days    :integer
#  need_date         :date
#  order_date        :date
#  part_description  :string
#  part_number       :string
#  purchase_order    :string
#  quantity_ordered  :decimal(12, 2)
#  quantity_received :decimal(12, 2)
#  receipt_date      :date
#  source_row_number :integer
#  supplier          :string
#  unit_cost         :decimal(12, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ops_import_id     :bigint           not null
#  program_id        :bigint           not null
#
class OpsMaterial < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :program_id, :ops_import_id, presence: true
end
