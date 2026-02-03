class ExportNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, export_type, format)
    user = User.find_by(id: user_id)
    return unless user

    ExportNotificationMailer.export_ready(user, export_type, format).deliver_now
  end
end
