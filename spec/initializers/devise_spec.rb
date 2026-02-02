require "rails_helper"

RSpec.describe "Devise configuration" do
  it "treats turbo stream as a navigational format" do
    expect(Devise.navigational_formats).to include(:turbo_stream)
  end
end
