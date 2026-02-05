# == Schema Information
#
# Table name: ops_shop_orders
#
#  id                 :bigint           not null, primary key
#  actual_finish      :date
#  actual_hours       :decimal(12, 2)
#  actual_start       :date
#  completed_quantity :decimal(12, 2)
#  due_date           :date
#  estimated_hours    :decimal(12, 2)
#  order_number       :string           not null
#  order_quantity     :decimal(12, 2)
#  part_description   :string
#  part_number        :string
#  planned_finish     :date
#  planned_start      :date
#  release_number     :string
#  remaining_quantity :decimal(12, 2)
#  source_row_number  :integer
#  status             :string
#  work_center        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ops_import_id      :bigint           not null
#  program_id         :bigint           not null
#
class OpsShopOrder < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :order_number, presence: true
  validates :program_id, :ops_import_id, presence: true
end
