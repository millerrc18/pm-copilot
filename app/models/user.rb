# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  THEME_OPTIONS = %w[light dark].freeze
  PALETTE_OPTIONS = %w[blue teal purple].freeze
  CONTRACTS_VIEW_OPTIONS = Contract::VIEW_OPTIONS

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :programs, dependent: :destroy

  validates :theme, inclusion: { in: THEME_OPTIONS }
  validates :palette, inclusion: { in: PALETTE_OPTIONS }
  validates :contracts_view, inclusion: { in: CONTRACTS_VIEW_OPTIONS }, allow_nil: true
  validates :first_name, :last_name, :job_title, :company, length: { maximum: 120 }, allow_blank: true
  validates :bio, length: { maximum: 600 }, allow_blank: true

  def admin?
    raw = ENV["ADMIN_EMAILS"].presence || ENV["ADMIN_EMAIL"].to_s
    admins = raw.split(/[,\s]+/).map { |e| e.strip.downcase }.reject(&:blank?)
    admins.include?(email.to_s.downcase)
  end

  def contracts_view_preference
    CONTRACTS_VIEW_OPTIONS.include?(contracts_view) ? contracts_view : nil
  end
end
