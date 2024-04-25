# frozen_string_literal: true

# This migration adds a `photo_url` column to the `places` table to store image URLs.
class AddPhotoUrlToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :photo_url, :string
  end
end
