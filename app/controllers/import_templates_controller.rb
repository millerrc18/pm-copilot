# frozen_string_literal: true

class ImportTemplatesController < ApplicationController
  before_action :authenticate_user!

  TEMPLATES = {
    "costs" => CostImportService::REQUIRED_HEADERS,
    "milestones" => MilestoneImportService::REQUIRED_HEADERS,
    "delivery_units" => DeliveryUnitImportService::REQUIRED_HEADERS
  }.freeze

  def show
    headers = TEMPLATES[params[:template]]
    return render plain: "Template not found.", status: :not_found if headers.nil?

    data = ImportTemplateBuilder.build(headers)
    filename = "#{params[:template]}.xlsx"

    send_data data,
              filename: filename,
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
end
