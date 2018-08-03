class SubscriptionUser < ApplicationRecord
  belongs_to :subscription
  belongs_to :user
  has_many :subscription_user_news_types
end
