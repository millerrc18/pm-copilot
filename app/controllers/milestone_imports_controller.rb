class MilestoneImportsController < ApplicationController
  before_action :authenticate_user!

  def new
    redirect_to imports_hub_path(tab: "milestones")
  end

  def create
    @programs = current_user.programs.order(:name)
    @active_tab = "milestones"
    @selected_program_id = params[:program_id]

    if params[:program_id].blank?
      @milestone_import_errors = [ "Please select a program." ]
      render "imports_hub/show", status: :unprocessable_entity
      return
    end

    @program = current_user.programs.find_by(id: params[:program_id])
    unless @program
      @milestone_import_errors = [ "Not authorized." ]
      render "imports_hub/show", status: :forbidden
      return
    end

    if params[:file].blank?
      @milestone_import_errors = [ "Please choose a file." ]
      render "imports_hub/show", status: :unprocessable_entity
      return
    end

    result = MilestoneImportService.new(user: current_user, program: @program, file: params[:file]).call

    if result[:errors].any?
      @milestone_import_errors = result[:errors]
      render "imports_hub/show", status: :unprocessable_entity
    else
      @milestone_import_result = result
      flash.now[:notice] = "Milestones imported. Created: #{result[:created]}, updated: #{result[:updated]}."
      render "imports_hub/show"
    end
  rescue StandardError => e
    @milestone_import_errors = [ "Import failed: #{e.message}" ]
    render "imports_hub/show", status: :unprocessable_entity
  end

  private
end
