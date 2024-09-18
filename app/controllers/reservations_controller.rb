class ReservationsController < ApplicationController
  def create
    restaurant = Restaurant.find(params[:restaurant_id])

    tables = restaurant.tables.where("size >= ?", reservation_params[:party_size]).to_a

    table = table_allocation(tables, reservation_params[:party_size], reservation_params[:start_time])

    if table
      reservation = table.reservations.create!(reservation_params)
      render json: reservation, status: :created
    else
      render json: { error: "No available table" }, status: :unprocessable_entity
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:party_size, :start_time, :duration)
  end

  def table_allocation(tables, party_size, start_time)
    # Sort tables by size and availability, then apply logic
    tables.sort_by(&:size).detect do |table|
      # Check if the table is available for the requested time
      table.reservations.none? { |r| time_overlap?(r.start_time, r.duration, start_time) }
    end
  end

  def time_overlap?(reservation_start, reservation_duration, requested_start)
    reservation_end = reservation_start + reservation_duration.minutes
    requested_end = requested_start + reservation_duration.minutes
    # check both start time and end time of existing reservations to ensure the new reservation doesn't conflict
    reservation_start <= requested_end && requested_start <= reservation_end
  end
end
