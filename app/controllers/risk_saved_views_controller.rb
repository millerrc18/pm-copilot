class RiskSavedViewsController < ApplicationController
  before_action :authenticate_user!

  def create
    filters = normalized_filters
    current_user.update!(risk_saved_filters: filters)
    redirect_to risks_path(filters), notice: "Risks and Opportunities view saved as default."
  end

  def destroy
    current_user.update!(risk_saved_filters: {})
    redirect_to risks_path, notice: "Saved Risks and Opportunities view cleared."
  end

  private

  def normalized_filters
    start_date = parsed_date(params[:start_date])
    end_date = parsed_date(params[:end_date])
    program_id = normalized_program_id
    contract_id = normalized_contract_id(program_id)

    {
      "program_id" => program_id,
      "contract_id" => contract_id,
      "risk_type" => params[:risk_type].presence,
      "status" => params[:status].presence,
      "owner" => params[:owner].presence,
      "owner_scope" => params[:owner_scope].presence,
      "query" => params[:query].presence,
      "start_date" => start_date&.to_s,
      "end_date" => end_date&.to_s
    }.compact_blank
  end

  def parsed_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end

  def normalized_program_id
    return nil if params[:program_id].blank?

    program = current_user.programs.find_by(id: params[:program_id])
    program&.id&.to_s
  end

  def normalized_contract_id(program_id)
    return nil if params[:contract_id].blank? || program_id.blank?

    contract = Contract.find_by(id: params[:contract_id], program_id: program_id)
    contract&.id&.to_s
  end
end
