# == Schema Information
#
# Table name: ops_mrb_part_details
#
#  id                :bigint           not null, primary key
#  closed_date       :date
#  created_date      :date
#  disposition       :string
#  extended_cost     :decimal(12, 2)
#  line_number       :string
#  mrb_number        :string           not null
#  part_description  :string
#  part_number       :string
#  quantity          :decimal(12, 2)
#  source_row_number :integer
#  status            :string
#  supplier          :string
#  unit_cost         :decimal(12, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ops_import_id     :bigint           not null
#  program_id        :bigint           not null
#
class OpsMrbPartDetail < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :mrb_number, presence: true
  validates :program_id, :ops_import_id, presence: true
end
