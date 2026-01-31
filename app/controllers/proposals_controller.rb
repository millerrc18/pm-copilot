class ProposalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @proposals = [
      { name: "Lumen Labs Expansion", stage: "Draft", value: "$1.2M", owner: "S. Park" },
      { name: "Atlas Renewals FY26", stage: "Submitted", value: "$3.4M", owner: "A. Rivera" },
      { name: "Northwind Pilot", stage: "Won", value: "$650K", owner: "D. Chen" }
    ]
  end

  def new; end
end
