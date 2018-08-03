class CreateSubscriptionUserNewsTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_user_news_types do |t|
      t.references :subscription_user, foreign_key: true
      t.references :news_type, foreign_key: true

      t.timestamps
    end

    UsersCompanyNewsType.all.each do |ucnt|

      subscription_user = SubscriptionUser.where(user_id: ucnt.users_company.user_id, subscription: Subscription.where(user_id: ucnt.users_company.consultant_id, company_id: ucnt.users_company.company_id).first).first
      SubscriptionUserNewsType.create(subscription_user: subscription_user, news_type: ucnt.news_type)
    end
  end
end
