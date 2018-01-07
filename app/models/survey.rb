# == Schema Information
#
# Table name: surveys
#
#  id            :uuid             not null, primary key
#  closing_time  :datetime
#  survey_pin    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  max_responses :integer
#  question      :string
#

class Survey < ApplicationRecord
  has_many :responses
  belongs_to :user
  validates :question, length: { minimum: 1, maximum: 1000 }
  
  # callback on the create method so that a PIN gets created only when saved correctly
  before_create do | survey |
    survey_pin = rand(1<<32).to_s(36)
    try_num = 0
    until((!Survey.exists?(:survey_pin => survey_pin)) or try_num < 100)
      survey_pin = rand(1<<32).to_s(36)
      # this just won't happen, but I don't want an infinite loop
      try_num += 1
    end
    survey.survey_pin = survey_pin
  end
end
