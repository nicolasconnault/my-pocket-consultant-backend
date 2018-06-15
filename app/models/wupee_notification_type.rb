class WupeeNotificationType < ApplicationRecord
  second_level_cache expires_in: 1.year
  has_many :role_notification_types
end
