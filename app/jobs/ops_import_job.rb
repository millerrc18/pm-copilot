class OpsImportJob < ApplicationJob
  queue_as :default
  after_enqueue :store_job_id

  def perform(ops_import_id)
    import = OpsImport.find(ops_import_id)
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    import.update!(status: "running", error_message: nil)
    Rails.logger.info(
      {
        message: "ops_import.started",
        ops_import_id: import.id,
        report_type: import.report_type,
        job_id: job_id
      }.to_json
    )

    result = nil
    import.source_file.blob.open do |file|
      result = OpsImportService.new(
        import: import,
        report_type: import.report_type,
        file_path: file.path
      ).call
    end

    if result&.ok
      import.update!(
        rows_imported: result.rows_imported,
        rows_rejected: result.rows_rejected,
        status: "succeeded",
        imported_at: Time.current,
        error_message: result.errors.first
      )
    else
      import.update!(
        status: "failed",
        imported_at: Time.current,
        error_message: result&.errors&.first || "Import failed"
      )
    end

    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round
    Rails.logger.info(
      {
        message: "ops_import.finished",
        ops_import_id: import.id,
        report_type: import.report_type,
        job_id: job_id,
        status: import.status,
        rows_imported: import.rows_imported,
        rows_rejected: import.rows_rejected,
        duration_ms: duration_ms
      }.to_json
    )
  rescue ActiveStorage::FileNotFoundError => e
    blob_key = import&.source_file&.blob&.key
    import&.update!(
      status: "failed",
      imported_at: Time.current,
      error_message: "Uploaded file not accessible by worker. Verify Active Storage is using shared storage (S3) in production."
    )
    Rails.logger.error(
      {
        message: "ops_import.missing_file",
        ops_import_id: ops_import_id,
        job_id: job_id,
        blob_key: blob_key,
        error_class: e.class.name,
        error_message: e.message
      }.to_json
    )
  rescue StandardError => e
    import&.update!(status: "failed", imported_at: Time.current, error_message: "Import crashed: #{e.class} - #{e.message}")
    Rails.logger.error(
      {
        message: "ops_import.failed",
        ops_import_id: ops_import_id,
        job_id: job_id,
        error_class: e.class.name,
        error_message: e.message
      }.to_json
    )
    raise
  end

  private

  def store_job_id
    import = OpsImport.find_by(id: arguments.first)
    return unless import

    import.update_column(:job_id, job_id)
  end
end
