# == Schema Information
#
# Table name: ops_imports
#
#  id            :bigint           not null, primary key
#  checksum      :string           not null
#  imported_at   :datetime
#  notes         :json             not null
#  report_type   :string           not null
#  rows_imported :integer          default(0), not null
#  rows_rejected :integer          default(0), not null
#  source_filename :string
#  status        :string           default("queued"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  imported_by_id :bigint          not null
#  program_id    :bigint           not null
#  error_message :string
#  job_id        :string
#
class OpsImport < ApplicationRecord
  REPORT_TYPES = %w[
    materials
    shop_orders
    shop_order_operations
    historical_efficiency
    scrap
    mrb_part_details
    mrb_dispo_lines
    bom
  ].freeze

  STATUSES = %w[queued running succeeded failed].freeze
  MAX_UPLOAD_SIZE = 10.megabytes

  belongs_to :program
  belongs_to :imported_by, class_name: "User"

  has_many :ops_materials, dependent: :delete_all
  has_many :ops_shop_orders, dependent: :delete_all
  has_many :ops_shop_order_operations, dependent: :delete_all
  has_many :ops_historical_efficiencies, dependent: :delete_all
  has_many :ops_scrap_records, dependent: :delete_all
  has_many :ops_mrb_part_details, dependent: :delete_all
  has_many :ops_mrb_dispo_lines, dependent: :delete_all
  has_many :ops_bom_components, dependent: :delete_all

  has_one_attached :source_file

  validates :report_type, presence: true, inclusion: { in: REPORT_TYPES }
  validates :checksum, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :assign_job_id, on: :create

  private

  def assign_job_id
    self.job_id ||= SecureRandom.uuid
  end
end
