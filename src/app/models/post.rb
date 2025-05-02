class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy # ← この行を追加
  validates :content, presence: true, length: { maximum: 1000 }
  validates :post_type, presence: true, inclusion: { in: %w(text image video) }
end