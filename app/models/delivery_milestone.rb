# == Schema Information
#
# Table name: delivery_milestones
#
#  id                       :bigint           not null, primary key
#  amendment_code           :string
#  amendment_effective_date :date
#  amendment_notes          :text
#  due_date                 :date
#  milestone_ref            :string           not null
#  notes                    :text
#  quantity_due             :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  contract_id              :bigint           not null
#
# Indexes
#
#  idx_dm_contract_ref                       (contract_id,milestone_ref) UNIQUE
#  index_delivery_milestones_on_contract_id  (contract_id)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => contracts.id)
#
class DeliveryMilestone < ApplicationRecord
  belongs_to :contract

  validates :due_date, presence: true
  validates :milestone_ref, presence: true, uniqueness: { scope: :contract_id }
  validates :quantity_due, numericality: { greater_than_or_equal_to: 0 }
end
