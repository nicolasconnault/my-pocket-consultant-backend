class PushNotificationDevice < ApplicationRecord
  has_many :user_devices
  has_many :users, through: :user_devices
  
  enum device_type: { android: 0, ios: 1 }

  validates :device_type, :push_token, presence: true
end
