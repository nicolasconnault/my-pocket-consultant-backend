class Company < ApplicationRecord
  belongs_to :company_category
  has_many :customer_users, class_name: "User", through: :users_companies, foreign_key: :user_id
  has_many :consultant_users, class_name: "User", through: :users_companies, foreign_key: :consultant_id
  has_many :users_companies

end
