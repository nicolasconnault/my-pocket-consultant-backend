# For sidekiq to run on production, check the upstart scripts here: https://github.com/mperham/sidekiq/tree/master/examples/upstart
class SendPushNotificationsJob < ApplicationJob
  queue_as :default

  def perform(devices, message)
    messages = devices.map {|d| { to: d.push_token, sound: message[:sound], body: message[:body], badge: message[:badge] } }
    client = Exponent::Push::Client.new
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
