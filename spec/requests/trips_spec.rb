# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Trips", type: :request do
  describe "GET /trips/search" do
    let!(:operator) { create(:operator, rating: 4.5) }

    let!(:bus) do
      create(
        :bus,
        operator: operator,
        name: "GreenLine Volvo",
        bus_type: "ac"
      )
    end

    let!(:seater_seat) do
      create(
        :seat,
        bus: bus,
        seat_number: "A1",
        seat_type: "seater"
      )
    end

    let!(:sleeper_seat) do
      create(
        :seat,
        bus: bus,
        seat_number: "A2",
        seat_type: "sleeper"
      )
    end

    let!(:wifi) { create(:amenity, name: "Wi-Fi") }

    let!(:charging) do
      create(:amenity, name: "Charging Point")
    end

    before do
      create(
        :bus_amenity,
        bus: bus,
        amenity: wifi
      )

      create(
        :bus_amenity,
        bus: bus,
        amenity: charging
      )
    end

    let!(:trip) do
      create(
        :trip,
        operator: operator,
        bus: bus,
        from_city: "Coimbatore",
        to_city: "Chennai",
        departure_at: Time.zone.parse("2026-09-20 21:00"),
        arrival_at: Time.zone.parse("2026-09-21 05:00"),
        price: 850
      )
    end

    before do
      create(
        :trip_seat,
        trip: trip,
        seat: seater_seat
      )

      create(
        :trip_seat,
        trip: trip,
        seat: sleeper_seat
      )
    end

    it "returns trips matching the search criteria" do
      get "/trips/search", params: {
        from_city: "Coimbatore",
        to_city: "Chennai",
        travel_date: "2026-09-20"
      }, as: :json

      expect(response).to have_http_status(:ok)

      body = response.parsed_body

      expect(body.size).to eq(1)
      expect(body.first["from_city"]).to eq("Coimbatore")
      expect(body.first["to_city"]).to eq("Chennai")
      expect(body.first["price"]).to eq("850.0")
    end

    it "returns operator details" do
      get "/trips/search", params: {
        from_city: "Coimbatore",
        to_city: "Chennai"
      }, as: :json

      body = response.parsed_body

      expect(body.first["operator"]["name"]).to eq(operator.name)
      expect(body.first["operator"]["rating"]).to eq("4.5")
    end

    it "returns bus details and amenities" do
      get "/trips/search", params: {
        from_city: "Coimbatore",
        to_city: "Chennai"
      }, as: :json

      body = response.parsed_body

      expect(body.first["bus"]["name"]).to eq("GreenLine Volvo")
      expect(body.first["bus"]["bus_type"]).to eq("ac")
      expect(body.first["bus"]["amenities"])
        .to contain_exactly("Wi-Fi", "Charging Point")
    end

    it "returns an empty array when no trips match" do
      get "/trips/search", params: {
        from_city: "Coimbatore",
        to_city: "Bangalore"
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end
  end
end