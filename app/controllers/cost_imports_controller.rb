class CostImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contract, if: -> { params[:contract_id].present? }

  def new; end

  def create
    if params[:file].blank?
      redirect_to(@contract ? new_contract_cost_import_path(@contract) : new_cost_import_path,
                  alert: "Please choose a file.")
      return
    end

    result = CostImportService.new(user: current_user, contract: @contract, file: params[:file]).call
    if @contract
      redirect_to contract_path(@contract),
                  notice: "Costs imported. Created: #{result[:created]}, updated: #{result[:updated]}."
    else
      message = [
        "Costs imported. Created: #{result[:created]}, updated: #{result[:updated]}.",
        summary_message(result[:per_contract])
      ].compact.join(" ")
      redirect_to programs_path, notice: message
    end
  rescue => e
    redirect_to(@contract ? new_contract_cost_import_path(@contract) : new_cost_import_path,
                alert: "Import failed: #{e.message}")
  end

  private

  def set_contract
    @contract = Contract.find(params[:contract_id])

    return if @contract.program.user_id == current_user.id

    redirect_to programs_path, alert: "Not authorized."
    return
  end

  def summary_message(per_contract)
    return nil if per_contract.blank?

    summary = per_contract.values.map do |entry|
      "#{entry[:contract_code]} (created: #{entry[:created]}, updated: #{entry[:updated]})"
    end

    "Per contract: #{summary.join(", ")}."
  end
end
