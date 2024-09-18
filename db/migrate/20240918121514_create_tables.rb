class CreateTables < ActiveRecord::Migration[7.2]
  def change
    create_table :tables do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.integer :size

      t.timestamps
    end
  end
end
