class User < ApplicationRecord
  second_level_cache expires_in: 1.week
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :lockable, :registerable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  delegate :can?, :cannot?, :to => :ability

  include Wupee::Receiver

  has_many :companies, through: :users_companies, foreign_key: :user_id
  has_many :consultant_companies, class_name: "Company", source: :company, through: :users_companies, foreign_key: :consultant_id
  has_many :users_companies
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: ":placeholder"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  def companies_with_consultants
    companies = []
    UsersCompany.where(user_id: self.id).each do |c|
      companies.push ({ 
        name: c.company.name, 
        label: c.company.label, 
        id: c.company.id, 
        consultantId: c.consultant_id, 
        first_name: (c.consultant.nil?) ? nil : c.consultant.first_name, 
        last_name: (c.consultant.nil?) ? nil : c.consultant.last_name
      })
    end
    companies
  end

  def email_required?
    false
  end

  def password_required?
    false
  end

  def has_roles? role_names, operator = :or
    Rails.cache.fetch("user/roles/#{self.id}/#{role_names.to_json}/#{operator}", expires_in: 24.hours) do
      result = true
      role_names.each do |role_name|
        has_any = self.roles.any? {|role| role.name == role_name.to_s} 
        if operator == :or && has_any
          return true
        end
        result = result && has_any
      end

      return result # If the operator is :or, by this point result will be false. If it's :and, it will be true if all roles were found, and false otherwise
    end
  end

  def has_role? role_name
    self.roles.any? {|role| role.name == role_name.to_s}
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def role_ids
    if !self.roles.blank?
      return self.roles.map {|role| role.id}
    end
    []
  end
end
