class CreateResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :responses do |t|
      t.text :entry
      t.text :cleaned_entry
      t.datetime :time_entered

      t.timestamps
    end
  end
end
