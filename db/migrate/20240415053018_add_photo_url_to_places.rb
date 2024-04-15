class AddPhotoUrlToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :photo_url, :string
  end
end
