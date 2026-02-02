require "rails_helper"
require "tempfile"

RSpec.describe "Import template downloads", type: :request do
  let(:user) { User.create!(email: "template-user@example.com", password: "password") }

  before do
    sign_in user
  end

  it "serves the cost template with required headers" do
    get import_template_path("costs")

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

    headers = read_headers(response.body)
    expect(headers).to eq(CostImportService::REQUIRED_HEADERS)
  end

  it "serves the milestone template with required headers" do
    get import_template_path("milestones")

    expect(response).to have_http_status(:ok)

    headers = read_headers(response.body)
    expect(headers).to eq(MilestoneImportService::REQUIRED_HEADERS)
  end

  it "serves the delivery unit template with required headers" do
    get import_template_path("delivery_units")

    expect(response).to have_http_status(:ok)

    headers = read_headers(response.body)
    expect(headers).to eq(DeliveryUnitImportService::REQUIRED_HEADERS)
  end

  def read_headers(body)
    file = Tempfile.new([ "template", ".xlsx" ])
    file.binmode
    file.write(body)
    file.close

    sheet = Roo::Excelx.new(file.path).sheet(0)
    sheet.row(1).map { |value| value.to_s.strip }
  end
end
