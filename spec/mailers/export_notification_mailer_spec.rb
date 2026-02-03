require "rails_helper"

RSpec.describe ExportNotificationMailer, type: :mailer do
  it "renders the export ready email" do
    user = User.create!(email: "mailer-export@example.com", password: "password", first_name: "Devon")

    mail = described_class.export_ready(user, "risk register", "pdf")

    expect(mail.subject).to eq("Your Risk Register export is ready")
    expect(mail.to).to contain_exactly(user.email)
    expect(mail.body.encoded).to include("risk register")
    expect(mail.body.encoded).to include("pdf")
  end
end
