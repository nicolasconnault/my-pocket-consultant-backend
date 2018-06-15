class Country < ApplicationRecord
  second_level_cache expires_in: 1.year
  has_many :topic_sections
end
