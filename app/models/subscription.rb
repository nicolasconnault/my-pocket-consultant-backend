class Subscription < ApplicationRecord
  belongs_to :company
  belongs_to :user
  has_many :news_items
end
