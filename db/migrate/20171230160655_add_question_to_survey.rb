class AddQuestionToSurvey < ActiveRecord::Migration[5.1]
  def change
    add_column :surveys, :question, :string
  end
end
