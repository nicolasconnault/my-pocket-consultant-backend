class CreateUserPushNotificationDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :user_push_notification_devices do |t|
      t.integer :user_id
      t.integer :push_notification_device_id

      t.timestamps
    end
  end
end
