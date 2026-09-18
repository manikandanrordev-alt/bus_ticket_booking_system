# frozen_string_literal: true

class TripSearchService
  def initialize(params = {})
    @params = params
  end

  def call
    scope = Trip.includes(:operator, :bus, :trip_seats)

    scope = filter_by_route(scope)
    scope = filter_by_travel_date(scope)
    scope = filter_by_operator_rating(scope)
    scope = filter_by_price(scope)
    scope = filter_by_bus_type(scope)
    scope = filter_by_seat_type(scope)
    scope = filter_by_amenities(scope)

    scope
  end

  private

  attr_reader :params

  def filter_by_route(scope)
    if params[:from_city].present?
      scope = scope.where(from_city: params[:from_city])
    end

    if params[:to_city].present?
      scope = scope.where(to_city: params[:to_city])
    end

    scope
  end

  def filter_by_travel_date(scope)
    return scope if params[:travel_date].blank?

    date = Date.parse(params[:travel_date].to_s)

    scope.where(
      departure_at: date.beginning_of_day..date.end_of_day
    )
  rescue ArgumentError
    scope.none
  end

  def filter_by_operator_rating(scope)
    return scope if params[:min_rating].blank?

    scope.joins(:operator)
         .where("operators.rating >= ?", params[:min_rating])
  end

  def filter_by_price(scope)
    if params[:min_price].present?
      scope = scope.where("trips.price >= ?", params[:min_price])
    end

    if params[:max_price].present?
      scope = scope.where("trips.price <= ?", params[:max_price])
    end

    scope
  end

  def filter_by_bus_type(scope)
    return scope if params[:bus_type].blank?

    scope.where(buses: { bus_type: params[:bus_type] })
  end

  def filter_by_seat_type(scope)
    return scope if params[:seat_type].blank?

    scope.joins(trip_seats: :seat)
         .where(seats: { seat_type: params[:seat_type] })
         .distinct
  end

  def filter_by_amenities(scope)
    return scope if params[:amenities].blank?

    requested_amenities = Array(params[:amenities]).reject(&:blank?)

    return scope if requested_amenities.empty?

    scope
      .joins(bus: :amenities)
      .where(amenities: { name: requested_amenities })
      .group("trips.id")
      .having("COUNT(DISTINCT amenities.id) = ?", requested_amenities.size)
  end
end