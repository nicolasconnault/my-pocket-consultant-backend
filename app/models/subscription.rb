class Subscription < ApplicationRecord
  belongs_to :company
  belongs_to :user
  has_many :news_items

  def customers
    UsersCompany.where(company_id: self.company_id, consultant_id: self.user_id).map {|uc| uc.user }
  end
end
