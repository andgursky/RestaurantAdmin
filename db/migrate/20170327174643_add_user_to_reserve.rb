class AddUserToReserve < ActiveRecord::Migration[5.0]
  def change
    add_reference :reserves, :user, foreign_key: true
  end
end
