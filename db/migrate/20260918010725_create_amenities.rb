class CreateAmenities < ActiveRecord::Migration[8.1]
  def change
    create_table :amenities do |t|
      t.string :name

      t.timestamps
    end
  end
end
