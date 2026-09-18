# frozen_string_literal: true

class CreateBookingSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_seats do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :trip_seat, null: false, foreign_key: true
      t.decimal :price, null: false, precision: 10, scale: 2

      t.timestamps
    end

    add_index :booking_seats, [:booking_id, :trip_seat_id], unique: true

    add_check_constraint(
      :booking_seats,
      "price >= 0",
      name: "booking_seats_price_check"
    )
  end
end