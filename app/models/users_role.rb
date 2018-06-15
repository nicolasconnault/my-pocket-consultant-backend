class UsersRole < ApplicationRecord
  second_level_cache expires_in: 1.week
end
