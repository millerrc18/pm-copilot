# == Schema Information
#
# Table name: ops_bom_components
#
#  id                    :bigint           not null, primary key
#  component_description :string
#  component_part_number :string           not null
#  effective_from        :date
#  effective_to          :date
#  level                 :integer
#  parent_part_number    :string           not null
#  quantity_per          :decimal(12, 4)
#  source_row_number     :integer
#  unit                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  ops_import_id         :bigint           not null
#  program_id            :bigint           not null
#
class OpsBomComponent < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :parent_part_number, :component_part_number, presence: true
  validates :program_id, :ops_import_id, presence: true
end
