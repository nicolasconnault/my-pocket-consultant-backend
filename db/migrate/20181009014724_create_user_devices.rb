class CreateUserDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :user_devices do |t|
      t.references :push_notification_device, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
