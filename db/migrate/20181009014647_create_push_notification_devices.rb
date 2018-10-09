class CreatePushNotificationDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :push_notification_devices do |t|
      t.string :device_type
      t.string :push_token

      t.timestamps
    end
  end
end
