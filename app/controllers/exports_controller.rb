class ExportsController < ApplicationController
  before_action :authenticate_user!

  def cost_hub
    entries = scoped_cost_entries
    export_format = export_format_param
    payload = Exports::CostEntriesExporter.new(entries: entries).public_send("to_#{export_format}")

    ExportNotificationJob.perform_later(current_user.id, "cost hub", export_format)

    send_data payload,
              filename: "cost-hub-#{Date.current}.#{export_format}",
              type: content_type_for(export_format)
  end

  def risks
    risks = scoped_risks
    export_format = export_format_param
    payload = Exports::RisksExporter.new(risks: risks).public_send("to_#{export_format}")

    ExportNotificationJob.perform_later(current_user.id, "risk register", export_format)

    send_data payload,
              filename: "risks-#{Date.current}.#{export_format}",
              type: content_type_for(export_format)
  end

  private

  def scoped_cost_entries
    entries = CostEntry.includes(:program)
      .joins(:program)
      .where(programs: { user_id: current_user.id })

    start_date = parse_date(params[:start_date]) || Date.current.beginning_of_month
    end_date = parse_date(params[:end_date]) || Date.current
    entries = entries.where(period_start_date: start_date..end_date)

    if params[:program_id].present?
      program = current_user.programs.find_by(id: params[:program_id])
      entries = program ? entries.where(program_id: program.id) : entries.none
    end

    entries.order(period_start_date: :asc)
  end

  def scoped_risks
    scope = Risk.for_user(current_user)
    scope = scope.where(program_id: params[:program_id]) if params[:program_id].present?
    scope = scope.where(contract_id: params[:contract_id]) if params[:contract_id].present?
    scope.order(due_date: :asc)
  end

  def export_format_param
    format = params[:format].to_s
    %w[xlsx pdf].include?(format) ? format : "xlsx"
  end

  def content_type_for(format)
    return "application/pdf" if format == "pdf"

    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end
end
