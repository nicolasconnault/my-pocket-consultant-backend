class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.references :news_item, foreign_key: true
      t.date :date_read

      t.timestamps
    end
  end
end
