class Operations::BaseController < ApplicationController
  include OperationsSchemaGuard

  before_action :authenticate_user!

  private

  def saved_filters_for(attribute)
    return {} unless current_user.respond_to?(:has_attribute?)
    return {} unless current_user.has_attribute?(attribute)

    current_user.public_send(attribute) || {}
  rescue NoMethodError
    {}
  end

  def default_date_range
    latest = Date.current
    [ latest - 90, latest ]
  end

  def initialize_procurement_empty_state
    @summary = {
      total_spend: 0.to_d,
      unique_parts: 0,
      top_supplier: nil,
      top_commodity: nil
    }
    @commodity_labels = []
    @commodity_totals = []
    @time_labels = []
    @time_values = []
    @parts = []
    @materials = []
    @no_materials = false
  end
end
