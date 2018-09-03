class Subscription < ApplicationRecord
  belongs_to :company
  belongs_to :user
  has_many :news_items
  has_many :subscription_users
  has_many :customers, class_name: "User", through: :subscription_users, source: :user
end
