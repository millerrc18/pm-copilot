# == Schema Information
#
# Table name: risk_exposure_snapshots
#
#  id                :bigint           not null, primary key
#  opportunity_total :integer          default(0), not null
#  risk_total        :integer          default(0), not null
#  snapshot_on       :date             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  program_id        :bigint           not null
#
# Indexes
#
#  index_risk_exposure_snapshots_on_program_id  (program_id)
#  index_risk_exposure_snapshots_on_program_id_and_snapshot_on  (program_id,snapshot_on) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#
class RiskExposureSnapshot < ApplicationRecord
  belongs_to :program

  validates :snapshot_on, presence: true
  validates :risk_total, :opportunity_total, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.capture_for_program(program, snapshot_on: Date.current, scope: nil)
    scope ||= Risk.where(program_id: program.id)
    totals = Risk.exposure_totals(scope)

    upsert(
      {
        program_id: program.id,
        snapshot_on: snapshot_on,
        risk_total: totals[:risk_total],
        opportunity_total: totals[:opportunity_total],
        created_at: Time.current,
        updated_at: Time.current
      },
      unique_by: :index_risk_exposure_snapshots_on_program_id_and_snapshot_on
    )
  end
end
