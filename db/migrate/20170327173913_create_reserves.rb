class CreateReserves < ActiveRecord::Migration[5.0]
  def change
    create_table :reserves do |t|
      t.integer :table_number
      t.string :time_start
      t.string :time_end

      t.timestamps
    end
  end
end
