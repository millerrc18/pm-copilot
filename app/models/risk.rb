# == Schema Information
#
# Table name: risks
#
#  id             :bigint           not null, primary key
#  description    :text
#  due_date       :date
#  impact         :integer          default(1), not null
#  owner          :string
#  probability    :integer          default(1), not null
#  risk_type      :string           not null
#  severity_score :integer          default(1), not null
#  status         :string           default("open"), not null
#  title          :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  contract_id    :bigint
#  program_id     :bigint
#
# Indexes
#
#  index_risks_on_contract_id  (contract_id)
#  index_risks_on_program_id   (program_id)
#  index_risks_on_risk_type    (risk_type)
#  index_risks_on_status       (status)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => contracts.id)
#  fk_rails_...  (program_id => programs.id)
#
class Risk < ApplicationRecord
  TYPES = %w[risk opportunity].freeze
  STATUSES = %w[open monitoring mitigated closed].freeze

  belongs_to :program, optional: true
  belongs_to :contract, optional: true

  validates :title, :risk_type, :status, presence: true
  validates :risk_type, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :probability, :impact,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validate :exactly_one_scope

  before_validation :update_severity_score

  scope :for_program, ->(program_id) { where(program_id: program_id) }
  scope :for_contract, ->(contract_id) { where(contract_id: contract_id) }
  scope :for_program_context, ->(program) {
    program_ids = Array(program).map(&:id)
    contract_ids = Contract.where(program_id: program_ids).select(:id)
    where(program_id: program_ids).or(where(contract_id: contract_ids))
  }

  def self.for_user(user)
    joins("LEFT JOIN programs AS risk_programs ON risk_programs.id = risks.program_id")
      .joins("LEFT JOIN contracts ON contracts.id = risks.contract_id")
      .joins("LEFT JOIN programs AS contract_programs ON contract_programs.id = contracts.program_id")
      .where("risk_programs.user_id = :user_id OR contract_programs.user_id = :user_id", user_id: user.id)
  end

  def severity_label
    case severity_score.to_i
    when 1..6
      "Low"
    when 7..12
      "Medium"
    when 13..20
      "High"
    else
      "Critical"
    end
  end

  private

  def update_severity_score
    return if probability.blank? || impact.blank?

    self.severity_score = probability.to_i * impact.to_i
  end

  def exactly_one_scope
    if program_id.present? && contract_id.present?
      errors.add(:base, "Select a program or a contract, not both.")
    elsif program_id.blank? && contract_id.blank?
      errors.add(:base, "Select a program or a contract.")
    end
  end
end
