class Subscription < ApplicationRecord
  belongs_to :company
  belongs_to :user
  has_many :news_items
  has_many :subscription_users
  has_many :customers, class_name: "User", through: :subscription_users, source: :user
  has_one_attached :news_item_temp_image

  def status
    if active
      "#{customers.size} customers"
    else
      'Inactive'
    end
  end
end
