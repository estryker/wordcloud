class CreateSurveys < ActiveRecord::Migration[5.1]
  def change
    create_table :surveys do |t|
      t.datetime :closing_time
      t.string :survey_pin

      t.timestamps
    end
  end
end
