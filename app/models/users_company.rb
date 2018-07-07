class UsersCompany < ApplicationRecord
  belongs_to :user
  belongs_to :consultant, class_name: "User", foreign_key: :consultant_id
  belongs_to :company
  has_many :news_types, through: :users_company_news_types
  has_many :users_company_news_types
end
