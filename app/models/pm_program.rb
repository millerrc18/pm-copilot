# == Schema Information
#
# Table name: pm_programs
#
#  id          :bigint           not null, primary key
#  customer    :string
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class PmProgram < ApplicationRecord
end
