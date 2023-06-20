class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true
      t.boolean :active
      t.string :website_url
      t.string :facebook_url
      t.string :twitter_url
    end
  end
end
