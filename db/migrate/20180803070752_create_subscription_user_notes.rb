class CreateSubscriptionUserNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_user_notes do |t|
      t.references :subscription_user, foreign_key: true
      t.text :note

      t.timestamps
    end
  end
end
