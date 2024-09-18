class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.references :table, null: false, foreign_key: true
      t.integer :party_size
      t.datetime :start_time
      t.integer :duration

      t.timestamps
    end
  end
end
