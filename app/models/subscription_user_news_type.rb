class SubscriptionUserNewsType < ApplicationRecord
  belongs_to :subscription_user
  belongs_to :news_type
end
