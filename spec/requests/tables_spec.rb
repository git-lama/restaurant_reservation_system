require 'rails_helper'

RSpec.describe "Tables API", type: :request do
  before(:each) do
    @restaurant = Restaurant.create!(name: "Test Restaurant")

    @table1 = Table.create!(size: 4, restaurant: @restaurant)
    @table2 = Table.create!(size: 6, restaurant: @restaurant)
    @table3 = Table.create!(size: 8, restaurant: @restaurant)


    @reservation1 = Reservation.create!(table: @table1, start_time: Time.now - 10.minutes, duration: 60, party_size: 4)
    @reservation2 = Reservation.create!(table: @table3, start_time: Time.now - 1.hour, duration: 150, party_size: 7)
  end

  describe "GET /restaurants/:restaurant_id/tables/occupied" do
    it "returns occupied tables for the specified time" do
      get "/restaurants/#{@restaurant.id}/tables/occupied", params: { time: Time.now }

      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)

      expect(json_response.size).to eq(2)

      expect(json_response).to include({
        "table_id" => @table1.id,
        "reservation_id" => @reservation1.id,
        "party_size" => @reservation1.party_size
      })

      expect(json_response).to include({
        "table_id" => @table3.id,
        "reservation_id" => @reservation2.id,
        "party_size" => @reservation2.party_size
      })
    end

    it "returns only tables occupied at the given time" do
      get "/restaurants/#{@restaurant.id}/tables/occupied", params: { time: Time.now + 4.hours }

      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)

      expect(json_response.size).to eq(0)
    end
  end
end
