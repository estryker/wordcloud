class AddUserToResponse < ActiveRecord::Migration[5.1]
  def change
    add_reference :responses, :user, foreign_key: true
  end
end
