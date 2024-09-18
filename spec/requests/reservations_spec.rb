 require 'rails_helper'

 RSpec.describe "Reservations", type: :request do
  describe "POST /reservations" do
    it "creates a reservation if a table is available" do
      restaurant = Restaurant.create!(name: "Test Restaurant")
      table = restaurant.tables.create!(size: 4)

      post "/restaurants/#{restaurant.id}/reservations", params: {
        reservation: { party_size: 4, start_time: Time.now, duration: 60 }
      }

      expect(response).to have_http_status(:created)
    end

    it "returns an error if no table is available" do
      restaurant = Restaurant.create!(name: "Test Restaurant")
      table = restaurant.tables.create!(size: 4)

      post "/restaurants/#{restaurant.id}/reservations", params: {
        reservation: { party_size: 5, start_time: Time.now, duration: 60 }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
   end
 end
