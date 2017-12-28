class AddMaxResponsesToSurveys < ActiveRecord::Migration[5.1]
  def change
    add_column :surveys, :max_responses, :integer
  end
end
