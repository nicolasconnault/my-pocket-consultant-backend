class CreateSubscriptionUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_users do |t|
      t.references :subscription, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :potential_recruit, default: false
      t.boolean :potential_host, default: false
      t.boolean :current_host, default: false

      t.timestamps
    end

    UsersCompany.all.each do |uc|
      subscription = Subscription.where(user_id: uc.consultant_id, company_id: uc.company_id).first
      SubscriptionUser.create(subscription: subscription, user_id: uc.user.id)
    end
  end
end
