class AddSurveyToResponse < ActiveRecord::Migration[5.1]
  def change
    add_reference :responses, :survey, foreign_key: true
  end
end
