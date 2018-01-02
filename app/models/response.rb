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
  belongs_to :survey# , type: :uuid
  validates :entry, presence: true

  before_create do | response |
    response.cleaned_entry = response.entry.split(" ").map {|word| word.downcase.sub(/^\W+/,"").sub(/\W+$/,"")}.join("")
  end
end
