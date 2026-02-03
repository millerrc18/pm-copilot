require "caxlsx"
require "prawn"

module Exports
  class RisksExporter
    def initialize(risks:)
      @risks = risks
    end

    def to_xlsx
      package = Axlsx::Package.new
      package.workbook.add_worksheet(name: "Risks") do |sheet|
        sheet.add_row [
          "Title",
          "Type",
          "Status",
          "Owner",
          "Due date",
          "Severity score",
          "Scope"
        ]
        @risks.each do |risk|
          sheet.add_row [
            risk.title,
            risk.risk_type,
            risk.status,
            risk.owner,
            risk.due_date,
            risk.severity_score,
            scope_label(risk)
          ]
        end
      end
      package.to_stream.read
    end

    def to_pdf
      Prawn::Document.new(page_size: "A4") do |pdf|
        pdf.text "Risk Register Export", size: 16, style: :bold
        pdf.move_down 10
        @risks.each do |risk|
          pdf.text [
            risk.title,
            risk.risk_type,
            risk.status,
            "Score #{risk.severity_score}"
          ].join(" - ")
        end
      end.render
    end

    private

    def scope_label(risk)
      return risk.program.name if risk.program
      return risk.contract.contract_code if risk.contract

      "Unassigned"
    end
  end
end
