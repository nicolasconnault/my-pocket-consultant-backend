class Company < ApplicationRecord
  belongs_to :company_category
  has_many :customer_users, class_name: "User", through: :subscription_users, foreign_key: :user_id
  has_many :consultant_users, class_name: "User", through: :subscriptions, foreign_key: :consultant_id
  has_many :subscription_users, through: :subscriptions, foreign_key: :company_id
  has_many :subscriptions
  has_many :subscribed_users, class_name: "User", source: :user, through: :subscriptions, foreign_key: :user_id
  has_many :company_tutorials
  has_many :company_news_types
  has_many :news_types, through: :company_news_types, dependent: :destroy
  has_many :users_companies, dependent: :destroy
  has_many :users, through: :users_companies, dependent: :destroy

  has_one_attached :logo

  def company_category_name
    company_category.name
  end
  def company_category_label
    company_category.label
  end
  def news_type_ids
    if !self.news_types.blank?
      return self.news_types.map {|nt| nt.id}
    end
    []
  end
end
