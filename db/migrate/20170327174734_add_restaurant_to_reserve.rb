class AddRestaurantToReserve < ActiveRecord::Migration[5.0]
  def change
    add_reference :reserves, :restaurant, foreign_key: true
  end
end
