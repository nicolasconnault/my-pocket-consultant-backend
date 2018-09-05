class UpgradeCallReminderDateToDateTime < ActiveRecord::Migration[5.2]
  def change
    change_column :subscription_user_call_reminders, :call_date, :datetime
  end
end
