# == Schema Information
#
# Table name: programs
#
#  id          :bigint           not null, primary key
#  customer    :string
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_programs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Program < ApplicationRecord
  belongs_to :user
  has_many :contracts, dependent: :destroy
  has_many :cost_entries, dependent: :nullify
  validates :name, presence: true

end
