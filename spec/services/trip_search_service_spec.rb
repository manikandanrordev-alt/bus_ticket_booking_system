# frozen_string_literal: true

require "rails_helper"

RSpec.describe TripSearchService do
  let!(:operator) { create(:operator, rating: 4.5) }
  let!(:bus) { create(:bus, operator: operator, bus_type: "ac") }

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
  let!(:charging) { create(:amenity, name: "Charging Point") }

  let!(:bus_wifi) do
    create(:bus_amenity, bus: bus, amenity: wifi)
  end

  let!(:bus_charging) do
    create(:bus_amenity, bus: bus, amenity: charging)
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
      seat: seater_seat,
      status: "available"
    )

    create(
      :trip_seat,
      trip: trip,
      seat: sleeper_seat,
      status: "available"
    )
  end

  describe "#call" do
    it "filters by route" do
      result = described_class.new(
        from_city: "Coimbatore",
        to_city: "Chennai"
      ).call

      expect(result).to contain_exactly(trip)
    end

    it "filters by travel date" do
      result = described_class.new(
        travel_date: "2026-09-20"
      ).call

      expect(result).to contain_exactly(trip)
    end

    it "filters by minimum operator rating" do
      result = described_class.new(
        min_rating: 4.5
      ).call

      expect(result).to contain_exactly(trip)
    end

    it "filters by maximum price" do
      result = described_class.new(
        max_price: 900
      ).call

      expect(result).to contain_exactly(trip)
    end

    it "filters by bus type" do
      result = described_class.new(
        bus_type: "ac"
      ).call

      expect(result).to contain_exactly(trip)
    end

    it "filters by seat type" do
      result = described_class.new(
        seat_type: "sleeper"
      ).call

      expect(result).to contain_exactly(trip)
    end

    it "filters by amenities" do
      result = described_class.new(
        amenities: ["Wi-Fi", "Charging Point"]
      ).call

      expect(result).to contain_exactly(trip)
    end

    it "returns no trips for an invalid travel date" do
      result = described_class.new(
        travel_date: "invalid-date"
      ).call

      expect(result).to be_empty
    end
  end
end