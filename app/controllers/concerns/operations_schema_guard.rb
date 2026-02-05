module OperationsSchemaGuard
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::StatementInvalid,
                ActiveModel::UnknownAttributeError,
                ActiveModel::MissingAttributeError,
                with: :render_operations_schema_missing
  end

  private

  def render_operations_schema_missing(exception)
    Rails.logger.error(
      "Operations schema missing or pending migrations. Run bin/rails db:migrate. " \
      "Exception: #{exception.class}: #{exception.message}"
    )

    respond_to do |format|
      format.html { render "operations/schema_missing", status: :service_unavailable }
      format.any { head :service_unavailable }
    end
  end
end
