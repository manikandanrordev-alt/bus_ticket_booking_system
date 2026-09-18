class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats do |t|
      t.references :bus, null: false, foreign_key: true
      t.string :seat_number
      t.string :seat_type

      t.timestamps
    end
  end
end
