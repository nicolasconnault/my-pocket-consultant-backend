# Push Notification related methods
#   To make push notification more easier
#   Please see https://github.com/rpush/rpush for more details
#
# @author alameen
#
class PushNotify
  MSGS = {
    invalid_app_type: 'Please provide a valid App type'
  }

  APP_NAME = {
    android: :android,
    ios: :ios
  }

  class << self
    # Pushes the message
    # @param type [Symbol] type of app
    # @param app_name [String] Name of the app
    # @param options [Hash] Notification options
    #
    # @return [Array/Boolean]
    def push(type, app_name, options)
      app = Rpush::Apns::App.find_by_name(type)
      if app.nil?
        app = Rpush::Gcm::App.find_by_name(type)
      end

      case type
      when :android
        push_android(app, options)
      when :ios
        push_ios(app, options)
      else
        [false, MSGS[:invalid_app_type]]
      end
    end

    def push_android(app, options)
      options = options.slice(:registration_ids, :data).merge(app: app)
      Rpush::Gcm::Notification.new(options).save!
    end

    def push_ios(app, options)
      options = options.slice(:device_token, :alert, :data).merge(app: app)
      Rpush::Apns::Notification.new(options).save!
    end
  end
end
