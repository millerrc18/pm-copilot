# == Schema Information
#
# Table name: delivery_units
#
#  id          :bigint           not null, primary key
#  notes       :text
#  ship_date   :date
#  unit_serial :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  contract_id :bigint           not null
#
# Indexes
#
#  index_delivery_units_on_contract_id                  (contract_id)
#  index_delivery_units_on_contract_id_and_unit_serial  (contract_id,unit_serial) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => contracts.id)
#
class DeliveryUnit < ApplicationRecord
  belongs_to :contract

  validates :unit_serial, presence: true, uniqueness: { scope: :contract_id }

  before_validation :normalize_ship_date

  private

  def normalize_ship_date
    raw_value = ship_date_before_type_cast
    return if raw_value.blank?
    return if ship_date.is_a?(Date)

    parsed = parse_ship_date(raw_value.to_s)
    if parsed
      self.ship_date = parsed
    else
      errors.add(:ship_date, "is not a valid date")
    end
  end

  def parse_ship_date(value)
    Date.iso8601(value)
  rescue Date::Error
    Date.strptime(value, "%m/%d/%Y")
  rescue Date::Error
    nil
  end
end
