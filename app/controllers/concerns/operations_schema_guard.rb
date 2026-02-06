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
    unless migrations_pending? || missing_schema_exception?(exception)
      raise exception
    end

    Rails.logger.error(
      "Operations schema missing or pending migrations. Run bin/rails db:migrate. " \
      "Exception: #{exception.class}: #{exception.message}"
    )

    respond_to do |format|
      format.html { render "operations/schema_missing", status: :service_unavailable }
      format.any { head :service_unavailable }
    end
  end

  def migrations_pending?
    ActiveRecord::Migration.check_pending_migrations
    false
  rescue ActiveRecord::PendingMigrationError
    true
  end

  def missing_schema_exception?(exception)
    message = exception.message.to_s.downcase
    message.include?("missing") || message.include?("does not exist") || message.include?("unknown column")
  end
end
