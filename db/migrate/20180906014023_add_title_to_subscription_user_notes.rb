class AddTitleToSubscriptionUserNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :subscription_user_notes, :title, :string
  end
end
