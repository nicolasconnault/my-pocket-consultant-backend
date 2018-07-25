class Company < ApplicationRecord
  belongs_to :company_category
  has_many :customer_users, class_name: "User", through: :users_companies, foreign_key: :user_id
  has_many :users_companies
  has_many :consultant_users, class_name: "User", through: :users_companies, foreign_key: :consultant_id
  has_many :subscriptions
  has_many :subscribed_users, class_name: "User", source: :user, through: :subscriptions, foreign_key: :user_id
  has_many :company_tutorials

  def company_category_name
    company_category.name
  end
  def company_category_label
    company_category.label
  end
end
