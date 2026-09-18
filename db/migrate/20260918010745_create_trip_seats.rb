class CreateTripSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_seats do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
