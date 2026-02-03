class ExportNotificationMailer < ApplicationMailer
  def export_ready(user, export_type, format)
    @user = user
    @export_type = export_type
    @format = format

    mail(
      to: @user.email,
      subject: "Your #{export_type.titleize} export is ready"
    )
  end
end
