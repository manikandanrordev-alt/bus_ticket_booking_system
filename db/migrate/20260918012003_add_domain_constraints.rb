# frozen_string_literal: true

class AddDomainConstraints < ActiveRecord::Migration[8.1]
  def change
    # Operators
    change_column_null :operators, :name, false
    change_column_null :operators, :rating, false
    change_column_default :operators, :rating, from: nil, to: 0

    add_check_constraint(
      :operators,
      "rating >= 0 AND rating <= 5",
      name: "operators_rating_range"
    )

    # Buses
    change_column_null :buses, :name, false
    change_column_null :buses, :bus_type, false

    # Seats
    change_column_null :seats, :seat_number, false
    change_column_null :seats, :seat_type, false

    add_index(
      :seats,
      [:bus_id, :seat_number],
      unique: true,
      name: "index_seats_on_bus_id_and_seat_number"
    )

    # Amenities
    change_column_null :amenities, :name, false

    add_index(
      :amenities,
      :name,
      unique: true,
      name: "index_amenities_on_name"
    )

    # Trips
    change_column_null :trips, :from_city, false
    change_column_null :trips, :to_city, false
    change_column_null :trips, :departure_at, false
    change_column_null :trips, :arrival_at, false
    change_column_null :trips, :price, false

    add_check_constraint(
      :trips,
      "price >= 0",
      name: "trips_price_non_negative"
    )

    add_check_constraint(
      :trips,
      "departure_at < arrival_at",
      name: "trips_departure_before_arrival"
    )

    add_index(
      :trips,
      [:from_city, :to_city, :departure_at],
      name: "index_trips_on_route_and_departure"
    )

    # Trip seats
    change_column_null :trip_seats, :status, false
    change_column_default :trip_seats, :status, from: nil, to: "available"

    add_check_constraint(
      :trip_seats,
      "status IN ('available', 'held', 'booked')",
      name: "trip_seats_status_check"
    )

    add_index(
      :trip_seats,
      [:trip_id, :seat_id],
      unique: true,
      name: "index_trip_seats_on_trip_id_and_seat_id"
    )

    add_index(
      :trip_seats,
      [:trip_id, :status],
      name: "index_trip_seats_on_trip_id_and_status"
    )
  end
end