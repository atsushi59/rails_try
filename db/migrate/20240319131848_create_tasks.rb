# frozen_string_literal: true

# This migration creates the `tasks` table in the database with appropriate fields.
class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :content
      t.boolean :is_done

      t.timestamps
    end
  end
end
