# frozen_string_literal: true

class ContractPeriodImporter
  HEADER_ALIASES = {
    "period_start_date" => ["period_start_date", "period start", "start", "week", "month"],
    "period_type"       => ["period_type", "period type", "type"],
    "units_delivered"   => ["units_delivered", "units", "delivered units"],
    "revenue_per_unit"  => ["revenue_per_unit", "sell_price", "price", "revenue/unit"],

    "hours_bam"         => ["hours_bam", "bam_hours", "bam hours"],
    "rate_bam"          => ["rate_bam", "bam_rate", "bam rate"],

    "hours_eng"         => ["hours_eng", "eng_hours", "eng hours"],
    "rate_eng"          => ["rate_eng", "eng_rate", "eng rate"],

    "hours_mfg_soft"    => ["hours_mfg_soft", "mfg_s_hours", "mfg (s) hours", "mfg soft hours"],
    "rate_mfg_soft"     => ["rate_mfg_soft", "mfg_s_rate", "mfg (s) rate", "mfg soft rate"],

    "hours_mfg_hard"    => ["hours_mfg_hard", "mfg_h_hours", "mfg (h) hours", "mfg hard hours"],
    "rate_mfg_hard"     => ["rate_mfg_hard", "mfg_h_rate", "mfg (h) rate", "mfg hard rate"],

    "hours_touch"       => ["hours_touch", "touch_hours", "touch labor hours"],
    "rate_touch"        => ["rate_touch", "touch_rate", "touch labor rate"],

    "material_cost"     => ["material_cost", "material", "material cost"],
    "other_costs"       => ["other_costs", "other", "other costs"]
  }.freeze

  REQUIRED = %w[period_start_date].freeze

  def initialize(contract:, file:)
    @contract = contract
    @file = file
  end

  def import!
    xlsx = Roo::Excelx.new(@file.tempfile.path) # Roo::Excelx reads .xlsx :contentReference[oaicite:2]{index=2}
    sheet = xlsx.sheet(0)

    raw_headers = sheet.row(1).map { |h| normalize(h) }
    header_map = build_header_map(raw_headers)

    missing = REQUIRED.reject { |attr| header_map.key?(attr) }
    if missing.any?
      return { ok: false, errors: ["Missing required column(s): #{missing.join(', ')}"] }
    end

    errors = []
    imported = 0

    # Use streaming iteration for efficiency :contentReference[oaicite:3]{index=3}
    xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
      row_values = row.map { |cell| cell&.value }
      next if row_values.compact.empty?

      attrs, row_errors = row_to_attrs(row_values, raw_headers, header_map)
      if row_errors.any?
        errors.concat(row_errors)
        next
      end

      period_start_date = attrs[:period_start_date]
      period_type = attrs[:period_type].presence || "month"

      record = ContractPeriod.find_or_initialize_by(
        contract: @contract,
        period_start_date: period_start_date,
        period_type: period_type
      )

      record.assign_attributes(attrs.except(:period_start_date, :period_type).merge(period_type: period_type))

      unless record.save
        errors << "Row #{attrs[:_row]}: #{record.errors.full_messages.join(', ')}"
        next
      end

      imported += 1
    end

    return { ok: false, errors: errors.uniq } if errors.any?
    { ok: true, imported: imported, errors: [] }
  rescue StandardError => e
    { ok: false, errors: ["Import crashed: #{e.class} - #{e.message}"] }
  end

  private

  def normalize(value)
    value.to_s.strip.downcase.gsub(/\s+/, " ").gsub(/[^\w\s\(\)\/-]/, "")
  end

  def build_header_map(raw_headers)
    map = {}
    HEADER_ALIASES.each do |attr, aliases|
      idx = raw_headers.find_index { |h| aliases.include?(h) }
      map[attr] = idx if idx
    end
    map
  end

  def row_to_attrs(values, headers, header_map)
    attrs = {}
    errs = []

    row_num = nil

    # Try to infer row number from Roo cell metadata when available
    # If not, we still return a useful error message without it.
    attrs[:_row] = "?"

    header_map.each do |attr, idx|
      attrs[attr.to_sym] = values[idx]
    end

    attrs[:period_start_date] = coerce_date(attrs[:period_start_date])
    if attrs[:period_start_date].nil?
      errs << "Row #{attrs[:_row]}: period_start_date is blank or invalid."
    end

    attrs[:units_delivered]  = coerce_int(attrs[:units_delivered])
    attrs[:revenue_per_unit] = coerce_decimal(attrs[:revenue_per_unit])

    %i[
      hours_bam hours_eng hours_mfg_soft hours_mfg_hard hours_touch
      rate_bam rate_eng rate_mfg_soft rate_mfg_hard rate_touch
      material_cost other_costs
    ].each do |k|
      attrs[k] = coerce_decimal(attrs[k])
    end

    [attrs, errs]
  end

  def coerce_date(v)
    return v.to_date if v.respond_to?(:to_date)
    return nil if v.nil?

    Date.parse(v.to_s)
  rescue ArgumentError
    nil
  end

  def coerce_int(v)
    return 0 if v.nil? || v.to_s.strip.empty?
    v.to_i
  end

  def coerce_decimal(v)
    return 0.0 if v.nil? || v.to_s.strip.empty?
    v.to_f
  end
end
