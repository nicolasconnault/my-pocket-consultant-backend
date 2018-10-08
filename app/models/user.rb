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

  has_many :subscription_users
  has_many :subscriptions
  has_many :subscribed_companies, class_name: "Company", source: :company, through: :subscriptions, foreign_key: :user_id
  has_many :notifications
  has_many :subscription_user_call_reminders, through: :subscription_users
  has_many :subscription_user_news_types, through: :subscription_users
  has_many :news_types, through: :subscription_user_news_types
  has_one :address
  has_many :user_push_notification_devices, dependent: :destroy
  has_many :push_notification_devices, through: :user_push_notification_devices

  has_one_attached :avatar

  # To add device info(type and token)
  #
  # @param attributes [Hash] device informations
  def add_device_info(attributes)
    return unless attributes.present? && attributes[:device_type].present? && attributes[:device_token].present?

    device_attr = attributes.slice(:device_type, :device_token)
    device_params = {
      device_type: PushNotificationDevice.device_types[device_attr[:device_type]],
      device_token: device_attr[:device_token]
    }

    device = PushNotificationDevice.where(device_params).first_or_initialize

    devices = push_notification_devices
    return if devices.include?(device)
    self.push_notification_devices << device
  end

  def notifications_by_company
    notifications.where('date_read IS NULL').order(created_at: :desc).first(20).map { |n| {
      id: n.id,
      newsItem: {
        title: n.news_item.title,
        description: n.news_item.description,
        startDate: n.news_item.start_date,
        endDate: n.news_item.end_date,
        type: n.news_item.news_type.name,
        url: n.news_item.url,
        id: n.news_item.id,
        regularPrice: n.news_item.regularPrice,
        discountedPrice: n.news_item.discountedPrice
      },
      company: {
        name: n.company.name,
        label: n.company.label,
        id: n.company.id
      },
    }}
  end

  def company_news_items company_id
    news_items = []
    self.subscription_users.all.each do |su|
      if su.subscription.company_id == company_id
        su.subscription.news_items.where(active: true).each do |ni|
          news_items.push ni
        end 
      end
    end
    news_items
  end

  def news_types_by_company
    sql = '
      SELECT 
      c.label AS "company_label",
      c.id AS "companyId",
      nt.id AS "id",
      nt.label AS "label",
      CASE WHEN nt.id IN (SELECT news_type_id FROM subscription_user_news_types sunt WHERE sunt.subscription_user_id = su.id) THEN true ELSE false END AS "status"

      FROM users

      LEFT JOIN subscription_users su ON su.user_id = users.id
      LEFT JOIN subscriptions s ON s.id = su.subscription_id
      LEFT JOIN companies c ON c.id = s.company_id
      LEFT JOIN company_news_types cnt ON c.id = cnt.company_id
      RIGHT OUTER JOIN news_types nt ON nt.id = cnt.news_type_id

      WHERE users.id = ' + self.id.to_s + '
      ORDER BY nt.label ASC'
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
    final_companies = {}
    user_companies = [] 
    UsersCompany.where(user_id: self.id).order(enabled: :desc).each do |uc|
      user_companies.push uc 
    end

    Company.includes(:company_category).all.group_by(&:company_category).each do |category, companies|
      full_companies = companies.map do |company| 
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
            result[:subscriptionId] = subscription.id
            result[:websiteUrl] = subscription.website_url
            result[:facebookUrl] = subscription.facebook_url
            result[:twitterUrl] = subscription.twitter_url
          end
        end
        result
      end
      final_companies[category.name] = full_companies.sort_by { |c| c[:enabled] ? 0 : 1 }
    end

    final_companies
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
    address.nil? ? nil : address.country
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
