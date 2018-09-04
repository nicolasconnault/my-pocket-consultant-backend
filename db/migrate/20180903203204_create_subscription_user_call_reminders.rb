class CreateSubscriptionUserCallReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_user_call_reminders do |t|
      t.references :subscription_user, foreign_key: true
      t.string :title
      t.date :call_date

      t.timestamps
    end
  end
end
