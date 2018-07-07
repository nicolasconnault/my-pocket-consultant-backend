class CompanyNewsType < ApplicationRecord
  belongs_to :news_type
  belongs_to :company
end
