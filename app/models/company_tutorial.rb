class CompanyTutorial < ApplicationRecord
  belongs_to :company
  belongs_to :tutorial_category
  has_many :tutorial_steps
end
