class Company < ApplicationRecord
  belongs_to :company_category
  has_many :customer_users, class_name: "User", through: :subscription_users, foreign_key: :user_id
  has_many :consultant_users, class_name: "User", through: :subscriptions, foreign_key: :consultant_id
  has_many :subscription_users, through: :subscriptions, foreign_key: :company_id
  has_many :subscriptions
  has_many :subscribed_users, class_name: "User", source: :user, through: :subscriptions, foreign_key: :user_id
  has_many :company_tutorials
  has_one_attached :logo

  def company_category_name
    company_category.name
  end
  def company_category_label
    company_category.label
  end
end
