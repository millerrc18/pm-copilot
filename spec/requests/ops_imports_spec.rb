require "rails_helper"
require "caxlsx"

RSpec.describe "Operations imports", type: :request do
  include ActiveJob::TestHelper

  def build_workbook(headers, rows)
    file = Tempfile.new([ "ops-import", ".xlsx" ])
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Sheet1") do |sheet|
      sheet.add_row(headers)
      rows.each { |row| sheet.add_row(row) }
    end
    package.serialize(file.path)
    file
  end

  let(:user) { User.create!(email: "ops-import-request@example.com", password: "password") }
  let(:program) { Program.create!(name: "Ops Program", user: user) }

  before { sign_in user, scope: :user }
  before { allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("") }

  it "creates an ops import and enqueues a job" do
    headers = OpsImportService::TEMPLATE_HEADERS.fetch("materials")
    file = build_workbook(
      headers,
      [ [ "PN-1", "Bracket", "Acme", "Steel", "Buyer", "PO-1", "2024-01-01", "2024-01-03", "2024-01-05", 5, 5, 10, 50, 3 ] ]
    )

    expect do
      post ops_imports_path, params: {
        program_id: program.id,
        report_type: "materials",
        file: Rack::Test::UploadedFile.new(file.path, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      }
    end.to change(OpsImport, :count).by(1)
      .and have_enqueued_job(OpsImportJob)

    job = enqueued_jobs.reverse.find { |entry| entry[:job] == OpsImportJob }
    import = OpsImport.find(job[:args].first)
    expect(import.job_id).to eq(job[:job_id])

    expect(response).to redirect_to(ops_imports_path(program_id: program.id))
  end

  it "rejects oversized files" do
    file = Tempfile.new([ "ops-import", ".xlsx" ])
    file.write("a" * (OpsImport::MAX_UPLOAD_SIZE + 1))
    file.rewind

    post ops_imports_path, params: {
      program_id: program.id,
      report_type: "materials",
      file: Rack::Test::UploadedFile.new(file.path, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("File is too large")
  end
end
