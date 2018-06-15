class Contact < ApplicationRecord
  belongs_to :owner, polymorphic: true
  second_level_cache expires_in: 1.week
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: ":placeholder"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
end
