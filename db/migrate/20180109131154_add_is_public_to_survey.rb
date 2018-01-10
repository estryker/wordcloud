class AddIsPublicToSurvey < ActiveRecord::Migration[5.1]
  def change
    add_column :surveys, :is_public, :boolean
  end
end
