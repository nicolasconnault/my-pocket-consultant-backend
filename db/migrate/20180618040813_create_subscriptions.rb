class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true
      t.boolean :active

      t.timestamps
    end
  end
end
