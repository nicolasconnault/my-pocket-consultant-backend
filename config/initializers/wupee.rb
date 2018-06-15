Wupee.mailer = NotificationsMailer
Wupee.deliver_when = :now

# uncomment and implement your logic here to avoid/permit email sending to your users
# leave it commented if you always want your users received emails
Wupee.email_sending_rule = Proc.new do |receiver, notification_type| 
  if !receiver.roles.empty? && !WupeeNotificationType.find_by_name(notification_type).nil?
    rnt = RoleNotificationType.where(role_id: receiver.role_ids, wupee_notification_type_id: notification_type.id, email: true)
    !rnt.empty?  
  end 
end

# uncomment and implement your logic here to avoid/permit email sending to your users
# leave it commented if you always want your users received notifications
Wupee.notification_sending_rule = Proc.new do |receiver, notification_type| 
  if !receiver.roles.empty?
    rnt = RoleNotificationType.where(role_id: receiver.role_ids, wupee_notification_type_id: notification_type.id, notify: true)
    !rnt.empty?  
  end 
end
