require "rails_helper"

RSpec.describe CostImportsController, type: :controller do
  describe "POST #create" do
    it "blocks imports for programs the user does not own" do
      owner = User.create!(email: "owner@example.com", password: "password")
      other = User.create!(email: "other@example.com", password: "password")
      program = Program.create!(name: "Program", user: owner)

      sign_in other

      post :create, params: { program_id: program.id }

      expect(response).to have_http_status(:forbidden)
      expect(flash[:alert]).to eq("Not authorized.")
    end
  end
end
