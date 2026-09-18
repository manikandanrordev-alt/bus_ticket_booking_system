# Clear existing data in dependency order
BookingSeat.delete_all
Booking.delete_all
HoldSeat.delete_all
Hold.delete_all
TripSeat.delete_all
Trip.delete_all
BusAmenity.delete_all
Seat.delete_all
Bus.delete_all
Amenity.delete_all
Operator.delete_all

# Operators
operators = [
  { name: "GreenLine Travels", rating: 4.6 },
  { name: "CityConnect Express", rating: 4.2 },
  { name: "SouthStar Bus", rating: 3.8 }
].map { |attributes| Operator.create!(attributes) }

greenline, city_connect, southstar = operators

# Amenities
wifi = Amenity.create!(name: "Wi-Fi")
charging = Amenity.create!(name: "Charging Point")
water = Amenity.create!(name: "Water Bottle")
blanket = Amenity.create!(name: "Blanket")

# Helper for creating buses and seats
def create_bus_with_seats(operator:, name:, bus_type:, seat_count:)
  bus = Bus.create!(
    operator: operator,
    name: name,
    bus_type: bus_type
  )

  seat_count.times do |index|
    seat_number = "A#{index + 1}"

    Seat.create!(
      bus: bus,
      seat_number: seat_number,
      seat_type: index.even? ? "seater" : "sleeper"
    )
  end

  bus
end

# Buses
greenline_bus = create_bus_with_seats(
  operator: greenline,
  name: "GreenLine Volvo",
  bus_type: "ac",
  seat_count: 10
)

city_connect_bus = create_bus_with_seats(
  operator: city_connect,
  name: "CityConnect Express",
  bus_type: "non_ac",
  seat_count: 10
)

southstar_bus = create_bus_with_seats(
  operator: southstar,
  name: "SouthStar Sleeper",
  bus_type: "ac",
  seat_count: 10
)

another_greenline_bus = create_bus_with_seats(
  operator: greenline,
  name: "GreenLine Premium",
  bus_type: "ac",
  seat_count: 10
)

# Bus amenities
[
  [greenline_bus, [wifi, charging, water]],
  [city_connect_bus, [charging, water]],
  [southstar_bus, [wifi, blanket]],
  [another_greenline_bus, [wifi, charging, blanket]]
].each do |bus, amenities|
  amenities.each do |amenity|
    BusAmenity.create!(bus: bus, amenity: amenity)
  end
end

# Helper for creating trips and their seat inventory
def create_trip_with_seats(
  operator:,
  bus:,
  from_city:,
  to_city:,
  departure_at:,
  arrival_at:,
  price:
)
  trip = Trip.create!(
    operator: operator,
    bus: bus,
    from_city: from_city,
    to_city: to_city,
    departure_at: departure_at,
    arrival_at: arrival_at,
    price: price
  )

  bus.seats.find_each do |seat|
    TripSeat.create!(
      trip: trip,
      seat: seat,
      status: "available"
    )
  end

  trip
end

today = Time.current.beginning_of_day

# Trips
create_trip_with_seats(
  operator: greenline,
  bus: greenline_bus,
  from_city: "Coimbatore",
  to_city: "Chennai",
  departure_at: today + 1.day + 21.hours,
  arrival_at: today + 2.days + 5.hours,
  price: 850
)

create_trip_with_seats(
  operator: city_connect,
  bus: city_connect_bus,
  from_city: "Coimbatore",
  to_city: "Chennai",
  departure_at: today + 1.day + 22.hours,
  arrival_at: today + 2.days + 6.hours,
  price: 650
)

create_trip_with_seats(
  operator: city_connect,
  bus: city_connect_bus,
  from_city: "Coimbatore",
  to_city: "Chennai",
  departure_at: today + 2.days + 22.hours,
  arrival_at: today + 3.days + 6.hours,
  price: 700
)

create_trip_with_seats(
  operator: southstar,
  bus: southstar_bus,
  from_city: "Coimbatore",
  to_city: "Bangalore",
  departure_at: today + 2.days + 20.hours,
  arrival_at: today + 3.days + 4.hours,
  price: 700
)

create_trip_with_seats(
  operator: greenline,
  bus: another_greenline_bus,
  from_city: "Chennai",
  to_city: "Bangalore",
  departure_at: today + 3.days + 21.hours,
  arrival_at: today + 4.days + 6.hours,
  price: 900
)



puts "Seed data created successfully."
puts "Operators: #{Operator.count}"
puts "Buses: #{Bus.count}"
puts "Seats: #{Seat.count}"
puts "Amenities: #{Amenity.count}"
puts "Bus amenities: #{BusAmenity.count}"
puts "Trips: #{Trip.count}"
puts "Trip seats: #{TripSeat.count}"
