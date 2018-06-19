class CompanyCategory < ApplicationRecord
  has_many :companies
  has_many :tutorial_categories
end
