class TutorialCategory < ApplicationRecord
  belongs_to :company_category
  has_many :company_tutorials
end
