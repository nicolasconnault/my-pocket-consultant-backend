class UsersCompanyNewsType < ApplicationRecord
  belongs_to :news_type
  belongs_to :users_company
end
