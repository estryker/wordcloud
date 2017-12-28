# == Schema Information
#
# Table name: responses
#
#  id            :integer          not null, primary key
#  entry         :text
#  cleaned_entry :text
#  time_entered  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Response < ApplicationRecord
  belongs_to :survey
end
