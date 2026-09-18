# frozen_string_literal: true

class TripSeatsController < ApplicationController
  before_action :authenticate_user!

  def show
    @trip = Trip.includes(trip_seats: :seat).find(params[:trip_id])
    @trip_seats = @trip.trip_seats.order(:id)
  end
end