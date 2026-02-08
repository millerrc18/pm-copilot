require "digest"

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
    @imports_last_updated_at = @imports.any? ? @imports.maximum(:updated_at) : nil

    if turbo_frame_request?
      render partial: "ops_imports/history",
             locals: { imports: @imports, program: @program, last_updated_at: @imports_last_updated_at }
    end
  end

  def create
    @programs = current_user.programs.order(:name)
    @program = current_user.programs.find_by(id: params[:program_id])
    file = params[:file]

    unless @program
      redirect_to ops_imports_path, alert: "Select a program to import Operations data."
      return
    end

    if params[:report_type].blank?
      redirect_to ops_imports_path(program_id: @program.id), alert: "Select a report type to import."
      return
    end

    unless OpsImport::REPORT_TYPES.include?(params[:report_type])
      @imports = OpsImport.where(program: @program).order(imported_at: :desc)
      @errors = [ "Unknown report type." ]
      render :index, status: :unprocessable_entity
      return
    end

    if file.blank?
      redirect_to ops_imports_path(program_id: @program.id), alert: "Attach a file to import."
      return
    end

    if file.size.to_i > OpsImport::MAX_UPLOAD_SIZE
      @imports = OpsImport.where(program: @program).order(imported_at: :desc)
      @errors = [ "File is too large. Max size is 10MB. Export a smaller date range or upgrade the instance size." ]
      render :index, status: :unprocessable_entity
      return
    end

    checksum = Digest::SHA256.file(file.tempfile.path).hexdigest
    if OpsImport.exists?(program: @program, report_type: params[:report_type], checksum: checksum)
      @imports = OpsImport.where(program: @program).order(imported_at: :desc)
      @errors = [ "This file has already been imported for this program." ]
      render :index, status: :unprocessable_entity
      return
    end

    import = OpsImport.create!(
      program: @program,
      imported_by: current_user,
      report_type: params[:report_type],
      source_filename: file.original_filename,
      checksum: checksum,
      status: "queued"
    )
    import.source_file.attach(file)

    job = OpsImportJob.perform_later(import.id)
    import.update_column(:job_id, job.job_id)
    Rails.logger.info(
      {
        message: "ops_import.enqueued",
        ops_import_id: import.id,
        report_type: import.report_type,
        job_id: job.job_id
      }.to_json
    )

    redirect_to ops_imports_path(program_id: @program.id), notice: "Import started. Refresh to see progress."
  end

  def destroy
    import = OpsImport.find(params[:id])
    unless current_user.admin?
      redirect_to ops_imports_path, alert: "Only admins can delete imports."
      return
    end

    import.destroy!
    @program = import.program
    @imports = OpsImport.where(program: @program).order(imported_at: :desc)
    @imports_last_updated_at = @imports.any? ? @imports.maximum(:updated_at) : nil

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Import deleted."
      end
      format.html do
        redirect_to ops_imports_path(program_id: import.program_id), notice: "Import deleted."
      end
    end
  end
end
