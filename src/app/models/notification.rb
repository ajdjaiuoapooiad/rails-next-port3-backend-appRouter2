class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :sender, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true
  validates :notification_type, presence: true, inclusion: { in: %w(like comment follow message) }
end