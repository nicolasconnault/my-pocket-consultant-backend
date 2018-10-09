namespace :cron do
  namespace :push_notifications do
    desc 'To be run daily at the start of the day: sends all notifications to subscribed users'
    task :send => :environment do
      # Get all news items that start today or end tomorrow
      news_items_starting_today = NewsItem.where(start_date: Date.today)
      news_items_ending_tomorrow = NewsItem.where(end_date: Date.tomorrow)

      news_items_starting_today.each do |ni|
        if ni.subscription.active
          message = {
            body: "#{ni.subscription.company.label} #{ni.title} starts today!",
            sound: nil,
            badge: 1
          }
          devices = []  
          ni.subscription.subscription_users.each do |su|
            su.user.push_notification_devices.each do |ud|
              devices.push ud
            end
          end

          SendPushNotificationsJob.perform_later(devices, message)
        end
      end

      news_items_ending_tomorrow.each do |ni|
        if ni.subscription.active
          message = {
            body: "#{ni.subscription.company.label} #{ni.title} ends tomorrow!",
            sound: "default",
            badge: 1
          }
          devices = []  
          ni.subscription.subscription_users.each do |su|
            su.user.push_notification_devices.each do |ud|
              devices.push ud
            end
          end

          SendPushNotificationsJob.perform_later(devices, message)
        end
      end
    end
  end
end
