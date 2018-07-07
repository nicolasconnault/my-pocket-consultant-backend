class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :news_item
  has_one :subscription, through: :news_item
  has_one :company, through: :subscription
end
