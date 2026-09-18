# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingRescheduleService do
  let!(:user) { create(:user) }

  let!(:operator) { create(:operator) }

  let!(:bus) do
    create(
      :bus,
      operator: operator,
      bus_type: "ac"
    )
  end

  let!(:seat_one) do
    create(
      :seat,
      bus: bus,
      seat_number: "A1",
      seat_type: "seater"
    )
  end

  let!(:seat_two) do
    create(
      :seat,
      bus: bus,
      seat_number: "A2",
      seat_type: "seater"
    )
  end

  let!(:new_seat_one) do
    create(
      :seat,
      bus: bus,
      seat_number: "A3",
      seat_type: "seater"
    )
  end

  let!(:new_seat_two) do
    create(
      :seat,
      bus: bus,
      seat_number: "A4",
      seat_type: "seater"
    )
  end

  let!(:trip) do
    create(
      :trip,
      operator: operator,
      bus: bus,
      from_city: "Coimbatore",
      to_city: "Chennai",
      price: 750.00,
      departure_at: 1.day.from_now,
      arrival_at: 1.day.from_now + 8.hours
    )
  end

  let!(:new_trip) do
    create(
      :trip,
      operator: operator,
      bus: bus,
      from_city: "Coimbatore",
      to_city: "Chennai",
      price: 800.00,
      departure_at: 2.days.from_now,
      arrival_at: 2.days.from_now + 8.hours
    )
  end

  let!(:old_trip_seat_one) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat_one,
      status: "booked"
    )
  end

  let!(:old_trip_seat_two) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat_two,
      status: "booked"
    )
  end

  let!(:new_trip_seat_one) do
    create(
      :trip_seat,
      trip: new_trip,
      seat: new_seat_one,
      status: "available"
    )
  end

  let!(:new_trip_seat_two) do
    create(
      :trip_seat,
      trip: new_trip,
      seat: new_seat_two,
      status: "available"
    )
  end

  let!(:hold) do
    create(
      :hold,
      user: user,
      expires_at: 5.minutes.ago,
      status: "converted"
    )
  end

  let!(:booking) do
    create(
      :booking,
      user: user,
      trip: trip,
      hold: hold,
      total_amount: 1500.00,
      status: "confirmed"
    )
  end

  before do
    create(
      :booking_seat,
      booking: booking,
      trip_seat: old_trip_seat_one,
      price: 750.00
    )

    create(
      :booking_seat,
      booking: booking,
      trip_seat: old_trip_seat_two,
      price: 750.00
    )
  end

  describe "#call" do
    it "reschedules the booking to another trip" do
      result = described_class.new(
        booking: booking,
        new_trip: new_trip
      ).call

      expect(result).to eq(booking)

      expect(booking.reload).to be_rescheduled
      expect(booking.trip).to eq(new_trip)
      expect(booking.total_amount).to eq(1600.00)

      expect(old_trip_seat_one.reload).to be_available
      expect(old_trip_seat_two.reload).to be_available

      expect(new_trip_seat_one.reload).to be_booked
      expect(new_trip_seat_two.reload).to be_booked

      expect(booking.booking_seats.map(&:trip_seat))
        .to contain_exactly(
          new_trip_seat_one,
          new_trip_seat_two
        )
    end

    it "rejects a trip from a different operator" do
      another_operator = create(:operator)

      another_bus = create(
        :bus,
        operator: another_operator
      )

      another_trip = create(
        :trip,
        operator: another_operator,
        bus: another_bus,
        from_city: "Coimbatore",
        to_city: "Chennai",
        departure_at: 2.days.from_now,
        arrival_at: 2.days.from_now + 8.hours
      )

      expect {
        described_class.new(
          booking: booking,
          new_trip: another_trip
        ).call
      }.to raise_error(
        ArgumentError,
        "Rescheduled trip must use the same operator"
      )

      expect(booking.reload).to be_confirmed
    end

    it "rejects a trip with a different route" do
      another_trip = create(
        :trip,
        operator: operator,
        bus: bus,
        from_city: "Coimbatore",
        to_city: "Bangalore",
        departure_at: 2.days.from_now,
        arrival_at: 2.days.from_now + 8.hours
      )

      expect {
        described_class.new(
          booking: booking,
          new_trip: another_trip
        ).call
      }.to raise_error(
        ArgumentError,
        "Rescheduled trip must use the same route"
      )

      expect(booking.reload).to be_confirmed
    end

    it "rejects a trip that does not have enough seats" do
      new_trip_seat_two.update!(status: "booked")

      expect {
        described_class.new(
          booking: booking,
          new_trip: new_trip
        ).call
      }.to raise_error(
        SeatUnavailableError,
        "Not enough seats are available on the selected trip"
      )

      expect(booking.reload).to be_confirmed
      expect(old_trip_seat_one.reload).to be_booked
      expect(old_trip_seat_two.reload).to be_booked
    end

    it "does not reschedule a cancelled booking" do
      booking.update!(status: "cancelled")

      expect {
        described_class.new(
          booking: booking,
          new_trip: new_trip
        ).call
      }.to raise_error(
        ArgumentError,
        "Only confirmed bookings can be rescheduled"
      )
    end
  end
end
