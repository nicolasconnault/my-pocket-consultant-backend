class NewsItem < ApplicationRecord
  belongs_to :news_type
  belongs_to :subscription
  has_many :notifications
end
