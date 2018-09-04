class SubscriptionUser < ApplicationRecord
  belongs_to :subscription
  belongs_to :user
  has_many :subscription_user_news_types
  has_many :subscription_user_notes
  has_many :subscription_user_call_reminders
end
