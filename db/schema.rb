# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_18_012003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "amenities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_amenities_on_name", unique: true
  end

  create_table "bus_amenities", force: :cascade do |t|
    t.bigint "amenity_id", null: false
    t.bigint "bus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_bus_amenities_on_amenity_id"
    t.index ["bus_id", "amenity_id"], name: "index_bus_amenities_on_bus_id_and_amenity_id", unique: true
    t.index ["bus_id"], name: "index_bus_amenities_on_bus_id"
  end

  create_table "buses", force: :cascade do |t|
    t.string "bus_type", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "operator_id", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_buses_on_operator_id"
  end

  create_table "operators", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "rating", default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "rating >= 0::numeric AND rating <= 5::numeric", name: "operators_rating_range"
  end

  create_table "seats", force: :cascade do |t|
    t.bigint "bus_id", null: false
    t.datetime "created_at", null: false
    t.string "seat_number", null: false
    t.string "seat_type", null: false
    t.datetime "updated_at", null: false
    t.index ["bus_id", "seat_number"], name: "index_seats_on_bus_id_and_seat_number", unique: true
    t.index ["bus_id"], name: "index_seats_on_bus_id"
  end

  create_table "trip_seats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "seat_id", null: false
    t.string "status", default: "available", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["seat_id"], name: "index_trip_seats_on_seat_id"
    t.index ["trip_id", "seat_id"], name: "index_trip_seats_on_trip_id_and_seat_id", unique: true
    t.index ["trip_id", "status"], name: "index_trip_seats_on_trip_id_and_status"
    t.index ["trip_id"], name: "index_trip_seats_on_trip_id"
    t.check_constraint "status::text = ANY (ARRAY['available'::character varying, 'held'::character varying, 'booked'::character varying]::text[])", name: "trip_seats_status_check"
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "arrival_at", null: false
    t.bigint "bus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "departure_at", null: false
    t.string "from_city", null: false
    t.bigint "operator_id", null: false
    t.decimal "price", null: false
    t.string "to_city", null: false
    t.datetime "updated_at", null: false
    t.index ["bus_id"], name: "index_trips_on_bus_id"
    t.index ["from_city", "to_city", "departure_at"], name: "index_trips_on_route_and_departure"
    t.index ["operator_id"], name: "index_trips_on_operator_id"
    t.check_constraint "departure_at < arrival_at", name: "trips_departure_before_arrival"
    t.check_constraint "price >= 0::numeric", name: "trips_price_non_negative"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "bus_amenities", "amenities"
  add_foreign_key "bus_amenities", "buses"
  add_foreign_key "buses", "operators"
  add_foreign_key "seats", "buses"
  add_foreign_key "trip_seats", "seats"
  add_foreign_key "trip_seats", "trips"
  add_foreign_key "trips", "buses"
  add_foreign_key "trips", "operators"
end
