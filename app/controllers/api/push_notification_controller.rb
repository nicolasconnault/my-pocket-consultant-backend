class Api::PushNotificationController < Api::ApplicationController
  before_action :doorkeeper_authorize!, except: [:register]

  def save_push_token
    user = current_resource_owner
    user.add_device_info({ device_type: params[:deviceType], device_token: params[:token] })
  end


end
