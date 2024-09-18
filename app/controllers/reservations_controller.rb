class ReservationsController < ApplicationController
  def create
    restaurant = Restaurant.find(params[:restaurant_id])
    reservation_start_time = reservation_params[:start_time].to_time
    reservation_end_time = (reservation_start_time + reservation_params[:duration].to_i.minutes).to_time

    table = restaurant.tables
              .where("size >= ?", reservation_params[:party_size])
              .left_joins(:reservations)
              .where("reservations.start_time IS NULL OR NOT (reservations.start_time < ? AND reservations.start_time + reservations.duration * interval '1 minute' > ?)",
                      reservation_end_time, reservation_start_time)
              .first
    # check both start time and end time of existing reservations to ensure the new reservation doesn't conflict

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
end
