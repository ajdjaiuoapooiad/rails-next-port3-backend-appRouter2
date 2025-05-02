class Profile < ApplicationRecord
  belongs_to :user, dependent: :destroy

  has_one_attached :user_icon
  has_one_attached :bg_image

end
