class TablesController < ApplicationController
  def occupied
    restaurant = Restaurant.find(params[:restaurant_id])

    requested_time = Time.zone.parse(params[:time])

    occupied_tables = restaurant.tables.joins(:reservations)
                          .where("? BETWEEN reservations.start_time AND (reservations.start_time + (reservations.duration * interval '1 minute'))", requested_time)
                          .select("tables.id AS table_id, reservations.id AS reservation_id, reservations.party_size")

    render json: occupied_tables.map { |table| {
      table_id: table.table_id,
      reservation_id: table.reservation_id,
      party_size: table.party_size
    }}
  end
end
