class CreateBuses < ActiveRecord::Migration[8.1]
  def change
    create_table :buses do |t|
      t.references :operator, null: false, foreign_key: true
      t.string :name
      t.string :bus_type

      t.timestamps
    end
  end
end
