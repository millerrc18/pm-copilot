class PlanItem < ApplicationRecord
  ITEM_TYPES = %w[initiative milestone deliverable task].freeze
  STATUSES = %w[planned in_progress blocked done].freeze

  belongs_to :program
  belongs_to :contract, optional: true
  belongs_to :owner, class_name: "User", optional: true

  has_many :outgoing_dependencies, class_name: "PlanDependency", foreign_key: :predecessor_id,
                                   dependent: :destroy, inverse_of: :predecessor
  has_many :incoming_dependencies, class_name: "PlanDependency", foreign_key: :successor_id,
                                   dependent: :destroy, inverse_of: :successor
  has_many :successors, through: :outgoing_dependencies, source: :successor
  has_many :predecessors, through: :incoming_dependencies, source: :predecessor

  validates :title, :item_type, :status, presence: true
  validates :item_type, inclusion: { in: ITEM_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :percent_complete, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
                               allow_nil: true
  validate :date_order

  private

  def date_order
    return if start_on.blank? || due_on.blank?
    return if start_on <= due_on

    errors.add(:start_on, "must be on or before the due date.")
  end
end
