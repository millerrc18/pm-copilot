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

  def set_scope
    if params[:contract_id].present?
      @contract = Contract.find(params[:contract_id])
      @program = @contract.program
    elsif params[:program_id].present?
      @program = Program.find(params[:program_id])
    end

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

  def new_cost_import_path
    return new_contract_cost_import_path(@contract) if @contract.present?
    return new_program_cost_import_path(@program) if @program.present?

    programs_path
  end

  def import_redirect_path
    return contract_path(@contract) if @contract.present?
    return program_path(@program) if @program.present?

    programs_path
  end

  def import_notice(result)
    base = "Costs imported. Created: #{result[:created]}, updated: #{result[:updated]}."
    return base if result[:per_contract].blank?

    breakdown = result[:per_contract].map do |code, counts|
      "#{code} (#{counts[:created]} created, #{counts[:updated]} updated)"
    end.join(", ")
    "#{base} By contract: #{breakdown}."
  end
end
