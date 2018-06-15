module ApplicationHelper
  def is_active_controller(controller_name)
    if controller_name.respond_to? 'each'
      controller_name.include?(params[:controller]) ? "active" : nil
    else
      params[:controller] == controller_name ? "active" : nil
    end
  end

  def is_active_action(action_name)
    if action_name.respond_to? 'each'
      action_name.include?(params[:action]) ? "active" : nil
    else
      params[:action] == action_name ? "active" : nil
    end
  end

  def current_device
    Device.find(cookies[:device_id])
  end
end
