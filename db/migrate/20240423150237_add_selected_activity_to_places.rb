# frozen_string_literal: true

# This migration adds a `selected_activity` column to the `places` table to describe the type of activities available.
class AddSelectedActivityToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :selected_activity, :string
  end
end
