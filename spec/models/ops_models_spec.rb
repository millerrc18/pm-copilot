require "rails_helper"

RSpec.describe "Operations models" do
  let(:user) { User.create!(email: "ops-models@example.com", password: "password") }
  let(:program) { Program.create!(name: "Ops Program", user: user) }
  let(:import) { OpsImport.create!(program: program, imported_by: user, report_type: "materials", checksum: "abc123") }

  it "validates OpsMaterial requires program and import" do
    record = OpsMaterial.new(part_number: "PN-1")
    expect(record).not_to be_valid

    record.program = program
    record.ops_import = import
    expect(record).to be_valid
  end

  it "validates OpsShopOrder requires order number" do
    record = OpsShopOrder.new(program: program, ops_import: import)
    expect(record).not_to be_valid

    record.order_number = "SO-1"
    expect(record).to be_valid
  end

  it "validates OpsShopOrderOperation requires order and operation number" do
    record = OpsShopOrderOperation.new(program: program, ops_import: import)
    expect(record).not_to be_valid

    record.order_number = "SO-1"
    record.operation_number = "10"
    expect(record).to be_valid
  end

  it "validates OpsHistoricalEfficiency requires program and import" do
    record = OpsHistoricalEfficiency.new
    expect(record).not_to be_valid

    record.program = program
    record.ops_import = import
    expect(record).to be_valid
  end

  it "validates OpsScrapRecord requires program and import" do
    record = OpsScrapRecord.new
    expect(record).not_to be_valid

    record.program = program
    record.ops_import = import
    expect(record).to be_valid
  end

  it "validates OpsMrbPartDetail requires mrb number" do
    record = OpsMrbPartDetail.new(program: program, ops_import: import)
    expect(record).not_to be_valid

    record.mrb_number = "MRB-1"
    expect(record).to be_valid
  end

  it "validates OpsMrbDispoLine requires mrb number" do
    record = OpsMrbDispoLine.new(program: program, ops_import: import)
    expect(record).not_to be_valid

    record.mrb_number = "MRB-1"
    expect(record).to be_valid
  end

  it "validates OpsBomComponent requires parent and component" do
    record = OpsBomComponent.new(program: program, ops_import: import)
    expect(record).not_to be_valid

    record.parent_part_number = "ASM-1"
    record.component_part_number = "COMP-1"
    expect(record).to be_valid
  end
end
