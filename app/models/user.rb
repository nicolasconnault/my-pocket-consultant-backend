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
  has_many :subscriptions
  has_many :subscribed_companies, class_name: "Company", source: :company, through: :subscriptions, foreign_key: :company_id
  has_many :subscriptions

  has_one :address
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: ":placeholder"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  def customer_companies
    # Uncomment below commented code when we upgrade to category-organised companies
    # final_companies = {}
    final_companies = []
    user_companies = [] 
    UsersCompany.where(user_id: self.id).each do |uc|
      user_companies.push uc 
    end

    # Company.includes(:company_category).all.group_by(&:company_category).each do |category, companies|
      # final_companies[category.name] = companies.map do |company| 
      final_companies = Company.all.map do |company| 
        enabled = user_companies.any?{|uc| uc.company.id == company.id && uc.enabled == true}
        result = { 
          name: company.name, 
          label: company.label, 
          id: company.id, 
          enabled: enabled,
          consultantId: nil,
          first_name: nil,
          last_name: nil,
          email: nil,
          phone: nil,
          websiteUrl: nil,
          facebookUrl: nil,
          twitterUrl: nil
        } 

        if enabled && !user_companies.find{|uc| uc.company_id == company.id}.consultant.nil?
          consultant = user_companies.find{|uc| uc.company_id == company.id}.consultant
          subscription = consultant.subscriptions.find_by_company_id(company.id)
          result[:last_name] = consultant.last_name
          result[:first_name] = consultant.first_name
          result[:email] = consultant.email
          result[:phone] = consultant.phone
          result[:consultantId] = consultant.id
          result[:websiteUrl] = subscription.website_url
          result[:facebookUrl] = subscription.facebook_url
          result[:twitterUrl] = subscription.twitter_url
        end
        result
      end
    #end

    final_companies
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
