class AddSelectedActivityToPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :places, :selected_activity, :string
  end
end
