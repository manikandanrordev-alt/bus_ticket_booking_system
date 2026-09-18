# frozen_string_literal: true

class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.references :hold, null: false, foreign_key: true

      t.decimal :total_amount, null: false, precision: 10, scale: 2
      t.string :status, null: false, default: "confirmed"
      t.string :idempotency_key, null: false

      t.timestamps
    end

    add_index :bookings, :idempotency_key, unique: true

    add_check_constraint(
      :bookings,
      "status IN ('confirmed', 'cancelled', 'rescheduled')",
      name: "bookings_status_check"
    )

    add_check_constraint(
      :bookings,
      "total_amount >= 0",
      name: "bookings_total_amount_check"
    )
  end
end