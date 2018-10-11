class Contact < ApplicationRecord
  belongs_to :owner, polymorphic: true
  second_level_cache expires_in: 1.week
  has_one_attached :avatar
end
