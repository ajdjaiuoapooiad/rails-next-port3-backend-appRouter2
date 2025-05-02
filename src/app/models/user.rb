class User < ApplicationRecord
  has_secure_password
  has_one :profile, dependent: :destroy

  # フォローする側の関連付け
  has_many :active_follows, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy
  has_many :followings, through: :active_follows, source: :following

  # フォローされる側の関連付け
  has_many :passive_follows, class_name: 'Follow', foreign_key: 'following_id', dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  # いいね機能の関連付けを追加
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  def following?(other_user)
    active_follows.exists?(following: other_user)
  end

  after_create :create_user_profile

  private

  def create_user_profile
    build_profile.save
  end

  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "は有効なメールアドレスではありません" }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true, length: { maximum: 50 }
end