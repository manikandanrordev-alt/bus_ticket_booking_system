class CreateBusAmenities < ActiveRecord::Migration[8.1]
  def change
    create_table :bus_amenities do |t|
      t.references :bus, null: false, foreign_key: true
      t.references :amenity, null: false, foreign_key: true

      t.timestamps
    end

    add_index :bus_amenities, [:bus_id, :amenity_id], unique: true
  end
end