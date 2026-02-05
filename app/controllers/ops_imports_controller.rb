class OpsImportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @programs = current_user.programs.order(:name)
    @program = current_user.programs.find_by(id: params[:program_id])
    @imports = if @program
      OpsImport.where(program: @program).order(imported_at: :desc)
    else
      []
    end
  end

  def create
    @programs = current_user.programs.order(:name)
    @program = current_user.programs.find_by(id: params[:program_id])

    unless @program
      redirect_to ops_imports_path, alert: "Select a program to import Operations data."
      return
    end

    if params[:report_type].blank?
      redirect_to ops_imports_path(program_id: @program.id), alert: "Select a report type to import."
      return
    end

    if params[:file].blank?
      redirect_to ops_imports_path(program_id: @program.id), alert: "Attach a file to import."
      return
    end

    result = OpsImportService.new(
      user: current_user,
      program: @program,
      report_type: params[:report_type],
      file: params[:file]
    ).call

    if result.ok
      redirect_to ops_imports_path(program_id: @program.id), notice: "Import complete."
    else
      @imports = OpsImport.where(program: @program).order(imported_at: :desc)
      @errors = result.errors
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    import = OpsImport.find(params[:id])
    unless current_user.admin?
      redirect_to ops_imports_path, alert: "Only admins can delete imports."
      return
    end

    import.destroy!
    redirect_to ops_imports_path(program_id: import.program_id), notice: "Import deleted."
  end
end
