class CreateProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.text :bio
      t.string :location
      t.string :website
      t.string :user_icon_url
      t.string :bg_image_url
      t.string :display_name
      t.string :avatar

      t.timestamps
    end
  end
end
