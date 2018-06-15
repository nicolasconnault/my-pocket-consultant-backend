class UsersCompany < ApplicationRecord
  belongs_to :user
  belongs_to :consultant, class_name: "User", foreign_key: :consultant_id
  belongs_to :company
end
