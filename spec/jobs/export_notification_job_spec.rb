require "rails_helper"

RSpec.describe ExportNotificationJob, type: :job do
  it "delivers an export notification email" do
    user = User.create!(email: "notify-export@example.com", password: "password", first_name: "Riley")

    expect {
      described_class.perform_now(user.id, "cost hub", "xlsx")
    }.to change { ActionMailer::Base.deliveries.count }.by(1)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq("Your Cost Hub export is ready")
    expect(mail.to).to contain_exactly(user.email)
  end
end
