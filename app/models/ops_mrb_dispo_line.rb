# == Schema Information
#
# Table name: ops_mrb_dispo_lines
#
#  id                  :bigint           not null, primary key
#  disposition         :string
#  disposition_cost    :decimal(12, 2)
#  disposition_date    :date
#  disposition_quantity :decimal(12, 2)
#  line_number         :string
#  mrb_number          :string           not null
#  responsible         :string
#  source_row_number   :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  ops_import_id       :bigint           not null
#  program_id          :bigint           not null
#
class OpsMrbDispoLine < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :mrb_number, presence: true
  validates :program_id, :ops_import_id, presence: true
end
