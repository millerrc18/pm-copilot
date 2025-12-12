class MilestoneImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contract

  def new; end

  def create
    if params[:file].blank?
      redirect_to new_contract_milestone_import_path(@contract), alert: "Please choose a file."
      return
    end

    result = MilestoneImportService.new(user: current_user, contract: @contract, file: params[:file]).call
    redirect_to contract_path(@contract), notice: "Milestones imported. Created: #{result[:created]}, updated: #{result[:updated]}."
  rescue => e
    redirect_to new_contract_milestone_import_path(@contract), alert: "Import failed: #{e.message}"
  end

  private

  def set_contract
    @contract = Contract.find(params[:contract_id])

    unless @contract.program.user_id == current_user.id
      redirect_to programs_path, alert: "Not authorized."
    end
  end
end
