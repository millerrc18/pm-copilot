require "rails_helper"

RSpec.describe OpsImportJob, type: :job do
  it "opens the attached blob and processes the import" do
    user = User.create!(email: "ops-import-job@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)
    import = OpsImport.create!(program: program, imported_by: user, report_type: "materials", checksum: "abc123")

    fixture = file_fixture("costs_import.xlsx")
    import.source_file.attach(
      io: File.open(fixture),
      filename: "costs_import.xlsx",
      content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    tempfile = Tempfile.new([ "ops-import", ".xlsx" ])
    FileUtils.copy_file(fixture, tempfile.path)

    result = Struct.new(:ok, :rows_imported, :rows_rejected, :errors).new(true, 3, 0, [])
    service = instance_double(OpsImportService, call: result)

    expect_any_instance_of(ActiveStorage::Blob).to receive(:open).and_yield(tempfile)
    expect(OpsImportService).to receive(:new).with(
      import: import,
      report_type: "materials",
      file_path: tempfile.path
    ).and_return(service)

    described_class.new.perform(import.id)

    import.reload
    expect(import.status).to eq("succeeded")
    expect(import.rows_imported).to eq(3)
    expect(import.rows_rejected).to eq(0)
  ensure
    tempfile.close
    tempfile.unlink
  end
end
