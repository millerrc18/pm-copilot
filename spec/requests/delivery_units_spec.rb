require "rails_helper"

RSpec.describe "Delivery units", type: :request do
  let(:user) { User.create!(email: "units@example.com", password: "password") }
  let(:program) { Program.create!(name: "Alpha Program", user: user) }
  let(:contract) do
    Contract.create!(
      program: program,
      contract_code: "ALPHA-200",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )
  end

  before { sign_in user, scope: :user }

  it "accepts ISO formatted ship dates" do
    post contract_delivery_units_path(contract), params: {
      delivery_unit: { unit_serial: "ALPHA-01", ship_date: "2024-02-10" }
    }

    expect(response).to redirect_to(contract_path(contract))
    expect(DeliveryUnit.last.ship_date).to eq(Date.new(2024, 2, 10))
  end

  it "accepts slash formatted ship dates" do
    post contract_delivery_units_path(contract), params: {
      delivery_unit: { unit_serial: "ALPHA-02", ship_date: "03/15/2024" }
    }

    expect(response).to redirect_to(contract_path(contract))
    expect(DeliveryUnit.last.ship_date).to eq(Date.new(2024, 3, 15))
  end
end
