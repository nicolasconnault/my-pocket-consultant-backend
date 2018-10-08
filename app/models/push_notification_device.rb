class PushNotificationDevice < ApplicationRecord
  has_many :user_push_notification_devices
  has_many :users, through: :user_push_notification_devices

  enum device_type: { android: 0, ios: 1 }

  validates :device_type, :device_token, presence: true

  class << self
    # [push_notification description]
    # @param devices [Array] Array of devices
    # @param data [Hash] Data to be passes with the notification
    def push_notification(devices, data)
      ios_device_tokens = get_device_tokens(devices, :ios)
      android_device_tokens = get_device_tokens(devices, :android)

      if android_device_tokens.present?
        options = { registration_ids: android_device_tokens, data: data }
        PushNotify.push(:android, PushNotify::APP_NAME[:android], options)
      end

      ios_device_tokens.each do |token|
        options = { device_token: token, data: data, alert: data[:message] }
        PushNotify.push(:ios, PushNotify::APP_NAME[:ios], options)
      end
    end

    # Fetch device tokens from device records of the matching device_type
    # @param devices [Array] Array of devices
    # @param device_type [Symbol] type of device
    #
    # @return [Array] Array of device tokens
    def get_device_tokens(devices, device_type)
      devices.select { |d| d.device_type.to_sym.eql?(device_type) }
        .map(&:device_token).uniq
    end
  end
end
