class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :user_name, null: false
      t.string :email, null: false
      t.string :name
      t.binary :avatar
      t.string :password_digest

      t.timestamps
    end
  end
end
