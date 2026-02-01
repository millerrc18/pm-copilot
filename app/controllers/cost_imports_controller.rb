class CostImportsController < ApplicationController
  before_action :authenticate_user!

  def new
    redirect_to imports_hub_path(tab: "costs")
  end

  def create
    @programs = current_user.programs.order(:name)
    @active_tab = "costs"
    @selected_program_id = params[:program_id]
    if params[:program_id].blank?
      @cost_import_errors = [ "Please select a program." ]
      render "imports_hub/show", status: :unprocessable_entity
      return
    end

    @program = current_user.programs.find_by(id: params[:program_id])
    unless @program
      @cost_import_errors = [ "Not authorized." ]
      render "imports_hub/show", status: :forbidden
      return
    end

    if params[:file].blank?
      @cost_import_errors = [ "Please choose a file." ]
      render "imports_hub/show", status: :unprocessable_entity
      return
    end

    result = CostImportService.new(user: current_user, program: @program, file: params[:file]).call

    if result[:errors].any?
      @cost_import_errors = result[:errors]
      render "imports_hub/show", status: :unprocessable_entity
    else
      @cost_import_result = result
      flash.now[:notice] = "Costs imported. Created: #{result[:created]}."
      render "imports_hub/show"
    end
  rescue StandardError => e
    @cost_import_errors = [ "Import failed: #{e.message}" ]
    render "imports_hub/show", status: :unprocessable_entity
  end

  private
end
