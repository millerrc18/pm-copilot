module Planning
  class TimelineBuilder
    Item = Struct.new(
      :kind,
      :title,
      :date,
      :subtitle,
      :program_name,
      :record,
      keyword_init: true
    )

    def initialize(programs:, item_type: nil)
      @programs = programs
      @item_type = item_type
    end

    def call
      items = []
      items.concat(contract_items) if include_type?("contracts")
      items.concat(milestone_items) if include_type?("milestones")
      items.concat(unit_items) if include_type?("delivery_units")

      items.compact.sort_by { |item| [ item.date || Date.current, item.title ] }
    end

    private

    def include_type?(type)
      return true if @item_type.blank?

      @item_type == type
    end

    def contract_items
      Contract.joins(:program)
        .where(programs: { id: @programs.select(:id) })
        .map do |contract|
          Item.new(
            kind: "contracts",
            title: contract.contract_code,
            date: contract.start_date,
            subtitle: "Contract period #{contract.start_date&.strftime('%b %-d, %Y')} to #{contract.end_date&.strftime('%b %-d, %Y')}",
            program_name: contract.program.name,
            record: contract
          )
        end
    end

    def milestone_items
      DeliveryMilestone.joins(contract: :program)
        .where(programs: { id: @programs.select(:id) })
        .map do |milestone|
          Item.new(
            kind: "milestones",
            title: milestone.milestone_ref.presence || "Milestone",
            date: milestone.due_date,
            subtitle: "#{milestone.contract.contract_code} · Qty #{milestone.quantity_due}",
            program_name: milestone.contract.program.name,
            record: milestone
          )
        end
    end

    def unit_items
      DeliveryUnit.joins(contract: :program)
        .where(programs: { id: @programs.select(:id) })
        .map do |unit|
          Item.new(
            kind: "delivery_units",
            title: unit.unit_serial.presence || "Delivered unit",
            date: unit.ship_date,
            subtitle: unit.contract.contract_code,
            program_name: unit.contract.program.name,
            record: unit
          )
        end
    end
  end
end
