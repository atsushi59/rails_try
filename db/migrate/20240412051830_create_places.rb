class CreatePlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :places do |t|
      t.string :name
      t.string :address
      t.string :website
      t.string :opening_hours

      t.timestamps
    end
  end
end
