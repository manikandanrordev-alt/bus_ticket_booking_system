# frozen_string_literal: true

class CreateHoldSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :hold_seats do |t|
      t.references :hold, null: false, foreign_key: true
      t.references :trip_seat, null: false, foreign_key: true
      t.timestamps
    end

    add_index :hold_seats, [:hold_id, :trip_seat_id], unique: true
  end
end