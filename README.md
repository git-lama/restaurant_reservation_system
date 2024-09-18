# Restaurant Reservation System API

## Overview

- This API provides a backend system for managing restaurant reservations and table allocations. The system is designed to handle operations such as creating reservations, managing table availability, and optimizing table assignments based on reservation size and restaurant capacity.

## Objective

- The API facilitates:

  - Creating reservations for a restaurant.
  - Listing occupied tables at a specific time.
  - Managing table allocations based on party size, availability, and restaurant capacity.

## System Design and Architectural Choices

The design for the Restaurant Reservation System API focuses on delivering a simple, efficient solution that adheres strictly to the requirements. The core objective was to keep the architecture as straightforward as possible.

### Key Architectural Decisions & Thoughts:

- Object-Oriented Approach: The system is structured around the core entities: Restaurant, Table, and Reservation. This allows for clear responsibilities and separation of concerns.
- First-Come, First-Served Allocation: By default, the system assigns tables based on availability and party size in a first-come, first-served manner. The logic is simple but effective for small to medium-sized restaurants.
- Time Overlap Handling: Overlapping reservations are prevented through time-based validation, ensuring a table is only reserved when available.
- Testing: The system is fully tested using RSpec to validate key functionality, including edge cases like overlapping reservations.
  This design is not over-engineered and meets the requirements without introducing unnecessary complexity, ensuring that performance remains optimal and the system is easy to maintain or extend.

### Core entities:

- Reservation
- Table
- Restaurant

## API Endpoints:

### Create a Reservation

- Endpoint: POST /reservations
  Request:

  Response:

### Get Occupied Tables

- Endpoint: GET /tables/occupied
  Request:

  Response:

## DB Models

Restaurant:

- id: integer, primary key
- name: string

Table:

- id: integer, primary key
- size: integer (number of seats)
- restaurant_id: integer, foreign key

Reservation:

- id: integer, primary key
- table_id: integer, foreign key
- party_size: integer
- start_time: datetime
- duration: integer (in minutes)

## Reservation Logic

### Table Assignment

Here's an explanation of the logic used:

- Finding Tables that Match Party Size:

`tables = restaurant.tables.where("size >= ?", reservation_params[:party_size]).to_a`

This finds all the tables in the restaurant that are large enough to accommodate the party size. The `where("size >= ?", reservation_params[:party_size])` condition filters out tables that cannot fit the party.

- Allocating an Available Table:

`table = table_allocation(tables, reservation_params[:party_size], reservation_params[:start_time])`

The table_allocation method sorts the filtered tables by size and checks if they are available at the requested time using the time_overlap? method.

- Table Allocation Logic:

`def table_allocation(tables, party_size, start_time)
  tables.sort_by(&:size).detect do |table|
    table.reservations.none? { |r| time_overlap?(r.start_time, r.duration, start_time) }
  end
end`

This sorts the tables by their size (sort_by(&:size)), prioritizing smaller tables to minimize gaps in reservations.
It checks if the table has any overlapping reservations using the `time_overlap?` method, ensuring the table is free during the requested time.

- Checking for Time Overlaps:

`def time_overlap?(reservation_start, reservation_duration, requested_start)
  reservation_end = reservation_start + reservation_duration.minutes
  requested_end = requested_start + reservation_duration.minutes
  reservation_start <= requested_end && requested_start <= reservation_end
end`

This method calculates the reservation end time by adding the duration to the start time. It checks whether the requested reservation overlaps with an existing one by ensuring that both the start and end times do not conflict.

## Testing

### Major Cases

- Valid Reservation Creation: Ensures reservations can be created when tables are available.
- Occupied Tables: Checks that the occupied tables endpoint accurately reflects table availability for a given time.

### Edge Cases:

- Overlapping reservations.
- No available tables for a given party size or time.

## Setup and Run Instructions

- Prerequisites
  To run this application, you'll need the following dependencies installed on your machine:

  - Ruby: Version 3.0.0+
  - Rails: Version 6.0+
  - PostgreSQL: Version 13 or higher
  - RSpec: For testing

Ensure you have all dependencies installed before proceeding.

### Steps to Set Up the Application

Clone the Repository: Open your terminal and run the following command to clone the repository:

`git clone https://github.com/your-repo/restaurant-reservation-api.git`
`cd restaurant-reservation-api`

Install Dependencies: Install all the necessary gems by running:

`bundle install`

Set Up the Database: Create, migrate, and seed the database using the following commands:

`rails db:create`
`rails db:migrate`
`rails db:seed`

This will create the PostgreSQL database, apply migrations, and seed it with initial data.

Run the Tests: To ensure everything is working correctly, run the RSpec test suite:

`bundle exec rspec`

This will execute all tests and confirm that the reservation system operates as expected.

Start the Rails Server: Once the database is set up, start the Rails server:

`rails server`

By default, the server will be available at `http://localhost:3000`.

API Endpoints

Create a Reservation: You can use cURL or Postman to make a POST request for creating a reservation. Here’s an example using cURL:

`curl -X POST http://localhost:3000/reservations -H "Content-Type: application/json" -d '{
  "reservation": {
    "restaurant_id": 1,
    "party_size": 4,
    "start_time": "2024-09-12T19:00:00",
    "duration": 2
  }
}'`

A successful response will return:

`{
  "message": "Reservation created successfully",
  "reservation_id": 1
}`

Get Occupied Tables: To check which tables are occupied at a certain time, you can run:

`curl -X GET "http://localhost:3000/tables/occupied?start_time=2024-09-12T19:00:00"`
This will return a list of occupied tables:

`[
  {
    "table_id": 1,
    "reservation_id": 5,
    "party_size": 4
  },
  {
    "table_id": 2,
    "reservation_id": 6,
    "party_size": 6
  }
]`

Accessing via Browser

Once the server is running, you can also open a browser and navigate to `http://localhost:3000/tables/occupied?start_time=2024-09-12T19:00:00` to view the occupied tables directly in the browser.

## Database Seeding

To populate the database with sample data, run:

`rails db:seed`

- Sample seed data:

## Challenges:

Handling overlapping reservations and testing edge cases was a significant focus.
Specifically, converting the duration of the reservation to minutes and comparing both the start and end times of new and existing reservations to ensure there were no conflicts was a key challenge.
