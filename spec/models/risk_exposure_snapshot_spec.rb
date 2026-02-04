require "rails_helper"

RSpec.describe RiskExposureSnapshot, type: :model do
  it "captures a program snapshot idempotently" do
    user = User.create!(email: "snapshot@example.com", password: "password")
    program = Program.create!(name: "Snapshot Program", user: user)

    Risk.create!(
      title: "Risk",
      risk_type: "risk",
      probability: 2,
      impact: 4,
      status: "open",
      program: program
    )

    described_class.capture_for_program(program, snapshot_on: Date.new(2024, 1, 1))
    described_class.capture_for_program(program, snapshot_on: Date.new(2024, 1, 1))

    snapshot = described_class.find_by!(program_id: program.id, snapshot_on: Date.new(2024, 1, 1))
    expect(snapshot.risk_total).to eq(8)
  end

  it "reduces exposure when a risk is closed in a later snapshot" do
    user = User.create!(email: "snapshot-change@example.com", password: "password")
    program = Program.create!(name: "Snapshot Program", user: user)

    risk = Risk.create!(
      title: "Risk",
      risk_type: "risk",
      probability: 5,
      impact: 2,
      status: "open",
      program: program
    )

    described_class.capture_for_program(program, snapshot_on: Date.new(2024, 1, 1))
    risk.update!(status: "closed")
    described_class.capture_for_program(program, snapshot_on: Date.new(2024, 1, 2))

    first_snapshot = described_class.find_by!(program_id: program.id, snapshot_on: Date.new(2024, 1, 1))
    second_snapshot = described_class.find_by!(program_id: program.id, snapshot_on: Date.new(2024, 1, 2))

    expect(second_snapshot.risk_total).to be < first_snapshot.risk_total
  end
end
