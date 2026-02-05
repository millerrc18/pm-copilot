# == Schema Information
#
# Table name: ops_shop_order_operations
#
#  id                :bigint           not null, primary key
#  actual_finish     :date
#  actual_start      :date
#  labor_hours       :decimal(12, 2)
#  operation_number  :string           not null
#  order_number      :string           not null
#  queue_time        :decimal(12, 2)
#  run_hours         :decimal(12, 2)
#  scheduled_finish  :date
#  scheduled_start   :date
#  sequence          :string
#  setup_hours       :decimal(12, 2)
#  source_row_number :integer
#  status            :string
#  work_center       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ops_import_id     :bigint           not null
#  program_id        :bigint           not null
#
class OpsShopOrderOperation < ApplicationRecord
  belongs_to :program
  belongs_to :ops_import

  validates :order_number, :operation_number, presence: true
  validates :program_id, :ops_import_id, presence: true
end
