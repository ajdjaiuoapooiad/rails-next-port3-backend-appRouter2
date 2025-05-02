class RemoveImageUrlColumnsFromProfiles < ActiveRecord::Migration[7.2]
  def change
    remove_column :profiles, :user_icon_url, :string
    remove_column :profiles, :bg_image_url, :string
    remove_column :profiles, :avatar, :string
  end
end
