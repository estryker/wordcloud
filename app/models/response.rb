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
#  survey_id     :uuid
#  user_id       :integer
#

class Response < ApplicationRecord
  belongs_to :survey# , type: :uuid
  belongs_to :user
  validates :entry, presence: true
  # filter = Stopwords::Snowball::Filter.new "en"
  stopwords = ["i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves", "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", "did", "doing", "would", "should", "could", "ought", "i'm", "you're", "he's", "she's", "it's", "we're", "they're", "i've", "you've", "we've", "they've", "i'd", "you'd", "he'd", "she'd", "we'd", "they'd", "i'll", "you'll", "he'll", "she'll", "we'll", "they'll", "isn't", "aren't", "wasn't", "weren't", "hasn't", "haven't", "hadn't", "doesn't", "don't", "didn't", "won't", "wouldn't", "shan't", "shouldn't", "can't", "cannot", "couldn't", "mustn't", "let's", "that's", "who's", "what's", "here's", "there's", "when's", "where's", "why's", "how's", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very"]
  before_create do | response |
    response.cleaned_entry = response.entry.split(" ").map {|word| word.downcase.sub(/^\W+/,"").sub(/\W+$/,"")}.uniq.delete_if {|word| stopwords.include? word}.join(" ")
    # response.cleaned_entry = filter.filter(response.entry).map {|word| word.downcase.sub(/^\W+/,"").sub(/\W+$/,"")}.join(" ")
  end
end
