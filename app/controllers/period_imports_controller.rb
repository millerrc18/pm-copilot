class PeriodImportsController < ApplicationController
  before_action :set_contract

  def new
  end

  def create
    file = params.dig(:period_import, :file)

    unless file.present?
      redirect_to new_contract_period_import_path(@contract), alert: "Please choose an .xlsx file."
      return
    end

    unless File.extname(file.original_filename).downcase == ".xlsx"
      redirect_to new_contract_period_import_path(@contract), alert: "Only .xlsx files are supported."
      return
    end

    result = ContractPeriodImporter.new(contract: @contract, file: file).import!

    if result[:ok]
      redirect_to contract_path(@contract), notice: "Imported #{result[:imported]} period rows."
    else
      @errors = result[:errors]
      flash.now[:alert] = "Import failed. Fix the issues below and re-upload."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_contract
    @contract = Contract.find(params[:contract_id])
  end
end

