class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.string :post_type
      t.string :media_url

      t.timestamps
    end
  end
end
