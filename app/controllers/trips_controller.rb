# frozen_string_literal: true

class TripsController < ApplicationController
  def search
	  @trips = TripSearchService.new(search_params).call

	  respond_to do |format|
	    format.html
	    format.json do
	      render json: @trips.map { |trip| trip_response(trip) }
	    end
	  end
	end

  private

  def search_params
    params.permit(
      :from_city,
      :to_city,
      :travel_date,
      :min_rating,
      :min_price,
      :max_price,
      :bus_type,
      :seat_type,
      amenities: []
    )
  end

  def trip_response(trip)
    {
      id: trip.id,
      from_city: trip.from_city,
      to_city: trip.to_city,
      departure_at: trip.departure_at,
      arrival_at: trip.arrival_at,
      price: trip.price,
      operator: {
        id: trip.operator.id,
        name: trip.operator.name,
        rating: trip.operator.rating
      },
      bus: {
        id: trip.bus.id,
        name: trip.bus.name,
        bus_type: trip.bus.bus_type,
        amenities: trip.bus.amenities.pluck(:name)
      }
    }
  end
end