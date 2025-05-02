class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :username
      t.string :display_name
      t.string :avatar

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
