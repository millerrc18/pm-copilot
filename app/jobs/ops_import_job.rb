class OpsImportJob < ApplicationJob
  queue_as :default

  def perform(ops_import_id)
    import = OpsImport.find(ops_import_id)
    import.update!(status: "running", error_message: nil)

    result = nil
    import.source_file.open do |file|
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
  rescue StandardError => e
    import&.update!(status: "failed", imported_at: Time.current, error_message: "Import crashed: #{e.class} - #{e.message}")
    Rails.logger.error(
      {
        message: "ops_import.failed",
        ops_import_id: ops_import_id,
        error_class: e.class.name,
        error_message: e.message
      }.to_json
    )
    raise
  end
end
