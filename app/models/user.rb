class User < ApplicationRecord
  second_level_cache expires_in: 1.week
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :lockable, :registerable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  delegate :can?, :cannot?, :to => :ability
  has_many :access_grants, class_name: "Doorkeeper::AccessGrant",
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens, class_name: "Doorkeeper::AccessToken",
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

  include Wupee::Receiver

  has_many :companies, through: :users_companies, foreign_key: :user_id
  has_many :consultant_companies, class_name: "Company", source: :company, through: :users_companies, foreign_key: :consultant_id
  has_many :users_companies
  has_many :subscriptions
  has_many :subscribed_companies, class_name: "Company", source: :company, through: :subscriptions, foreign_key: :company_id
  has_many :subscriptions
  has_many :notifications
  has_many :news_types, through: :users_company_news_types
  has_many :users_company_news_types, through: :users_companies
  has_one :address
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: ":placeholder"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  def notifications_by_company
    notifications.where('date_read IS NULL').order(created_at: :desc).first(20).map { |n| {
      title: n.news_item.title,
      description: n.news_item.description,
      startDate: n.news_item.start_date,
      endDate: n.news_item.end_date,
      type: n.news_item.news_type.name,
      companyLabel: n.company.label,
      companyId: n.company.id
    }}
  end

  def news_types_by_company
    sql = '
      SELECT 
      c.label AS "company_label",
      c.id AS "companyId",
      nt.id AS "id",
      nt.label AS "label",
      CASE WHEN nt.id IN (SELECT news_type_id FROM users_company_news_types ucnt WHERE ucnt.users_company_id = uc.id) THEN true ELSE false END AS "status"

      FROM users

      LEFT JOIN users_companies uc ON uc.user_id = users.id
      LEFT JOIN companies c ON c.id = uc.company_id
      LEFT JOIN company_news_types cnt ON c.id = cnt.company_id
      RIGHT OUTER JOIN news_types nt ON nt.id = cnt.news_type_id

      WHERE users.id = ' + self.id.to_s + '
      ORDER BY status DESC'
    hash = ActiveRecord::Base.connection.exec_query(sql).to_hash
    news_types_object = {}

    hash.each do |h|
      if news_types_object[h['company_label']].nil?
        news_types_object[h['company_label']] = []
      end
      news_types_object[h['company_label']].push({
        id: h['id'],
        label: h['label'],
        status: h['status']
      })
    end
    news_types_object
  end

  def customer_companies
    # Uncomment below commented code when we upgrade to category-organised companies
    # final_companies = {}
    final_companies = []
    user_companies = [] 
    UsersCompany.where(user_id: self.id).order(enabled: :desc).each do |uc|
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
          firstName: nil,
          lastName: nil,
          email: nil,
          phone: nil,
          websiteUrl: nil,
          facebookUrl: nil,
          twitterUrl: nil
        } 

        if enabled && !user_companies.find{|uc| uc.company_id == company.id}.consultant.nil?
          consultant = user_companies.find{|uc| uc.company_id == company.id}.consultant
          subscription = consultant.subscriptions.find_by_company_id(company.id)
          result[:lastName] = consultant.last_name
          result[:firstName] = consultant.first_name
          result[:email] = consultant.email
          result[:phone] = consultant.phone
          result[:consultantId] = consultant.id
          if subscription
            result[:websiteUrl] = subscription.website_url
            result[:facebookUrl] = subscription.facebook_url
            result[:twitterUrl] = subscription.twitter_url
          end
        end
        result
      end
    #end

    final_companies.sort_by { |c| c[:enabled] ? 0 : 1 }
  end

  def email_required?
    false
  end

  def password_required?
    false
  end

  def suburb
    address.nil? ? nil : address.suburb
  end
  def state
    address.nil? ? nil : address.state
  end
  def postcode
    address.nil? ? nil : address.postcode
  end
  def postcode
    address.nil? ? nil : address.postcode
  end
  def country
    address.nil? ? nil : address.country.name
  end
  def street1
    address.nil? ? nil : address.street1
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
