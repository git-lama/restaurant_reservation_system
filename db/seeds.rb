restaurant = Restaurant.create!(name: "Sample Restaurant")
restaurant.tables.create!([{ size: 2 }, { size: 4 }, { size: 6 }, {size: 10}])
