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

    it "does not allow overlapping reservation" do

      table = Table.last
      table.reservations.create!(
        party_size: 4,
        start_time: Time.now + 1.hour,
        duration: 2
      )

      # Attempt to create another reservation with overlapping time
      post "/reservations", params: {
        reservation: {
          restaurant_id: restaurant.id,
          party_size: 4,
          start_time: Time.now + 1.hour + 30.minutes, # Overlapping time
          duration: 2
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("No available table")
    end
   end
 end
