# frozen_string_literal: true

require "rubygems"
rubyzip_spec = Gem::Specification.find_by_name("rubyzip")
require File.join(rubyzip_spec.full_gem_path, "lib/zip")
require "caxlsx"

class ImportTemplateBuilder
  def self.build(headers, rows = [])
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Template") do |sheet|
      sheet.add_row(headers)
      rows.each { |row| sheet.add_row(row) }
    end
    package.to_stream.read
  end
end
