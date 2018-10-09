class PushNotificationDevice < ApplicationRecord
  has_many :user_devices
  has_many :users, through: :user_devices
  
  enum device_type: { android: 0, ios: 1 }

  validates :device_type, :push_token, presence: true

  class << self
    # @param devices [Array] Array of devices
    # @param data [Hash] Data to be passes with the notification
    def push_notification(devices, message)
      client = Exponent::Push::Client.new

      messages = devices.map {|d| { to: d.push_token, sound: message[:sound], body: message[:body], badge: message[:badge] } }
      begin
        client.publish messages
      rescue Exponent::Push::DeviceNotRegisteredError => e
        matches = e.message.match '"(.*)" is not a registered'
        if matches[1]
          device = PushNotificationDevice.find_by_push_token(matches[1])
          if !device.nil?
            UserDevice.where(push_notification_device_id: device.id).each { |ud| ud.destroy }
            device.destroy!
          end
        end 
      end
    end
  end
end
