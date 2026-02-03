require "caxlsx"
require "prawn"

module Exports
  class CostEntriesExporter
    def initialize(entries:)
      @entries = entries
    end

    def to_xlsx
      package = Axlsx::Package.new
      package.workbook.add_worksheet(name: "Cost entries") do |sheet|
        sheet.add_row [
          "Program",
          "Period type",
          "Period start",
          "Labor hours",
          "Material cost",
          "Other costs",
          "Total cost"
        ]
        @entries.each do |entry|
          sheet.add_row [
            entry.program.name,
            entry.period_type,
            entry.period_start_date,
            entry.total_labor_hours.to_f,
            entry.material_cost.to_d.to_f,
            entry.other_costs.to_d.to_f,
            entry.total_cost.to_d.to_f
          ]
        end
      end
      package.to_stream.read
    end

    def to_pdf
      Prawn::Document.new(page_size: "A4") do |pdf|
        pdf.text "Cost Hub Export", size: 16, style: :bold
        pdf.move_down 10
        @entries.each do |entry|
          pdf.text [
            entry.program.name,
            entry.period_start_date,
            "Total cost: #{format_currency(entry.total_cost)}"
          ].join(" - ")
        end
      end.render
    end

    private

    def format_currency(value)
      format("$%.2f", value.to_d)
    end
  end
end
