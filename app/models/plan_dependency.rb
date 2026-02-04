require "set"

class PlanDependency < ApplicationRecord
  TYPES = %w[blocks relates].freeze

  belongs_to :predecessor, class_name: "PlanItem", inverse_of: :outgoing_dependencies
  belongs_to :successor, class_name: "PlanItem", inverse_of: :incoming_dependencies

  validates :dependency_type, inclusion: { in: TYPES }
  validate :no_self_reference
  validate :no_cycle

  private

  def no_self_reference
    return if predecessor_id.blank? || successor_id.blank?
    return unless predecessor_id == successor_id

    errors.add(:successor_id, "cannot depend on itself.")
  end

  def no_cycle
    return if predecessor.blank? || successor.blank?
    return if predecessor_id == successor_id

    return unless cycle_exists?

    errors.add(:base, "Dependency would create a cycle.")
  end

  def cycle_exists?
    visited = Set.new
    stack = [ successor ]

    while (current = stack.pop)
      return true if current.id == predecessor_id
      next if visited.include?(current.id)

      visited.add(current.id)
      current.successors.each { |item| stack << item }
    end

    false
  end
end
