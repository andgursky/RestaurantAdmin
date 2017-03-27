class CreateRestaurants < ActiveRecord::Migration[5.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.integer :tables_count
      t.string :time_open
      t.string :time_close

      t.timestamps
    end
  end
end
