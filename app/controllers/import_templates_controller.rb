# frozen_string_literal: true

class ImportTemplatesController < ApplicationController
  before_action :authenticate_user!

  TEMPLATES = {
    "costs" => CostImportService::REQUIRED_HEADERS,
    "milestones" => MilestoneImportService::REQUIRED_HEADERS,
    "delivery_units" => DeliveryUnitImportService::REQUIRED_HEADERS,
    "materials" => OpsImportService::TEMPLATE_HEADERS.fetch("materials"),
    "shop_orders" => OpsImportService::TEMPLATE_HEADERS.fetch("shop_orders"),
    "shop_order_operations" => OpsImportService::TEMPLATE_HEADERS.fetch("shop_order_operations"),
    "historical_efficiency" => OpsImportService::TEMPLATE_HEADERS.fetch("historical_efficiency"),
    "scrap" => OpsImportService::TEMPLATE_HEADERS.fetch("scrap"),
    "mrb_part_details" => OpsImportService::TEMPLATE_HEADERS.fetch("mrb_part_details"),
    "mrb_dispo_lines" => OpsImportService::TEMPLATE_HEADERS.fetch("mrb_dispo_lines"),
    "bom" => OpsImportService::TEMPLATE_HEADERS.fetch("bom")
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
