class CreateNotifications < ActiveRecord::Migration[7.2] # Railsのバージョンに合わせて適宜修正
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :sender, null: true, foreign_key: { to_table: :users } # ここを修正
      t.string :notifiable_type, null: false
      t.integer :notifiable_id, null: false
      t.string :notification_type, null: false
      t.datetime :read_at

      t.timestamps
    end
  end
end
