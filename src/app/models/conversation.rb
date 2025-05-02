class Conversation < ApplicationRecord
    has_many :conversation_users, dependent: :destroy
    has_many :users, through: :conversation_users
    has_many :messages, dependent: :destroy
  
    # ユーザーIDのペアで既存の会話を見つけるスコープ (1対1チャット用)
    scope :between, -> (user_id_1, user_id_2) {
      joins(:conversation_users).where(conversation_users: { user_id: user_id_1 })
      .joins(:conversation_users).where(conversation_users: { user_id: user_id_2 })
      .group('conversations.id')
      .having('COUNT(conversation_users.user_id) = 2')
    }
end