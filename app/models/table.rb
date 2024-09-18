class Table < ApplicationRecord
  belongs_to :restaurant
  has_many :reservations
end
