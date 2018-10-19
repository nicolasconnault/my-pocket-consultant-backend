class Api::CustomerController < Api::ApplicationController

  before_action :doorkeeper_authorize!, except: [:register]

  def consultants
    respond_to do |format| 
      format.json {
        render json: {
          results: Subscription.where(company_id: params[:companyId]).map do |s|
            country_object = (s.user.address.nil?) ? { code: nil } : {
              id: s.user.address.country.id,
              name: s.user.address.country.name,
              code: s.user.address.country.code
            }
            {
              id: s.user.id,
              username: s.user.email,
              firstName: s.user.first_name,
              lastName: s.user.last_name,
              name: "#{s.user.last_name} #{s.user.first_name}",
              street: s.user.street1,
              suburb: s.user.suburb,
              postcode: s.user.postcode,
              state: s.user.state,
              phone: s.user.phone,
              country: country_object,
              # companies: s.user.subscribed_companies.map {|c| { id: c.id, name: c.name, label: c.label } }
            }
          end
        }
      }
    end
  end

  def register
    existing_user = User.find_by_username(params[:username])
    if !existing_user.nil? && !existing_user.email.nil?
      render json: { 
        error: 'Email address is already in use.',
        errorField: 'username'
      }, status: 422
    else
      # If a previous unconfirmed account exists with this username, delete it first
      if !existing_user.nil?
        existing_user.destroy!
      end
      user = User.create(
        username: params[:username],
        first_name: params[:firstName],
        last_name: params[:lastName],
        unconfirmed_email: params[:username],
        password: params[:password],
      )
      country = Country.find_by_code(params[:countryCode])
      unless country.nil? || params[:timeZone].nil?
        user.address = Address.create(postcode: params[:postcode], country: country, timezone: params[:timeZone])
      end

      # Confirmable will now attempt to send an email confirmation. Ignore sending errors if we are in dev mode
      begin
        user.save!
      rescue OpenSSL::SSL::SSLError
        if Rails.env.production?
          # Handle error appropriately
        else 
          # Ignore error
        end
      end

      # User is not yet confirmed. Devise automatically generated a very long token with user.save!, but let's provide a 4-digit PIN instead, easier to enter for mobile users
      user = User.last
      user.confirmation_token = 4.times.map{rand(10)}.join
      user.save!
      access_token = Doorkeeper::AccessToken.create!(:resource_owner_id => user.id)
      render json: { confirmationPin: user.confirmation_token, accessToken: Doorkeeper::OAuth::TokenResponse.new(access_token).body["access_token"] }
      # TODO if the email is not confirmed within a certain time, the DoorKeeper token should also be deleted
    end
  end

  # PIN should have already been confirmed in the App, this method is only meant to record the confirmation in the DB using Devise fields
  def email_confirmation
    user = current_resource_owner
    user.email = user.unconfirmed_email
    user.unconfirmed_email = nil
    user.confirmed_at = Time.now
  end

  # Just in case we need this at some stage
  def send_sms
    sns = Aws::SNS::Client.new(
      access_key_id: Rails.application.credentials.aws[:access_key_id], 
      secret_access_key: Rails.application.credentials.aws[:secret_access_key], 
      region: Rails.application.credentials.aws[:region]
    )
    response = sns.publish(phone_number: SOME_PHONE_NUMBER, message: MESSAGE) # e.g., { message_id: b6eeb3d1-e532-5bc6-8482-e790aff07433 }
  end

  def save_profile
    user = current_resource_owner
    
    # TODO handle change of email address
    # TODO handle change of password
    user.update_attributes(
      username: params[:username],
      first_name: params[:firstName],
      last_name: params[:lastName],
      email: params[:username],
      password: params[:password],
      phone: params[:phone]
    )

    if user.address.nil?
      user.address = Address.create(
        street1: params[:street],
        postcode: params[:postcode],
        suburb: params[:suburb],
      )
    else
      user.address.update_attributes(
        street1: params[:street],
        postcode: params[:postcode],
        suburb: params[:suburb],
      )
    end
    user_details
  end

  def tutorials
    result = {}
    
    Company.all.each do |company|
      result[company.label] ||= {}

      company.company_tutorials.each do |tutorial|
        result[company.label][tutorial.tutorial_category.title] ||= []

        tutorial_object = { id: tutorial.id, title: tutorial.title, steps: []} 
        tutorial.tutorial_steps.each do |step|

          tutorial_object[:steps].push ({
            id: step.id,
            title: step.title,
            description: step.description,
            video: step.video
          })
        end

        result[company.label][tutorial.tutorial_category.title].push tutorial_object
      end
    end

    respond_to do |format| 
      format.json {
        render json: {results: result }
      }
    end
  end
 
  def notifications
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: {results: user.notifications_by_company }
      }
    end
  end

  # Some news types only apply to some companies, so we retrieve the news types organised by company
  # e.g., [
  #         'Scentsy': [{id: 5, label: 'exclusive Products', status: true}, {id: 6, label: 'New Products', status: true}],
  #         'Enjo': [{id: 5, label: 'exclusive Products', status: true}, {id: 6, label: 'New Products', status: true}],
  #       ]
  def news_types
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: {results: user.news_types_by_company }
      }
    end
  end

  def company_news_items
    user = current_resource_owner

    respond_to do |format| 
      format.json {
        render json: {results: user.company_news_items(params[:companyId]).map {|n| { 
          title: n.title,
          description: n.description,
          startDate: n.start_date,
          endDate: n.end_date,
          type: n.news_type.name,
          url: n.url,
          id: n.id,
          regularPrice: n.regularPrice,
          discountedPrice: n.discountedPrice,
          imageUrl: (n.image.attached?) ? url_for(n.image.variant(resize: '400x300')) : nil
        } } }
      }
    end
  end

  def user_details
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        country_object = (user.address.nil?) ? { code: nil } : {
          id: user.address.country.id,
          name: user.address.country.name,
          code: user.address.country.code
        }

        render json: {
          results: { 
            id: user.id, 
            username: user.email,
            firstName: user.first_name, 
            lastName: user.last_name,
            street: user.street1,
            suburb: user.suburb,
            postcode: user.postcode,
            state: user.state,
            phone: user.phone,
            country: country_object,
            countryCode: country_object[:code],
            confirmed: user.confirmed?,
          } 
        }
      }
    end
  end

  def customer_companies
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: {results: user.customer_companies }
      }
    end
  end

  def select_consultant
    user = current_resource_owner
    uc = UsersCompany.where(user_id: user.id, company_id: params[:companyId]).first
    uc.consultant_id = params[:consultantId]
    uc.save!
    render json: {results: user.customer_companies }

  end

  def toggle_company
    user = current_resource_owner
    if params[:oldValue] == true
      if uc = UsersCompany.where(user_id: user.id, company_id: params[:companyId]).first
        uc.update_attribute(:enabled, false)
      end
    else
      uc_params = { user_id: user.id, company_id: params[:companyId] }
      if uc = UsersCompany.where(uc_params).first
        uc_params['enabled'] = true
        uc.update(uc_params)
      else
        UsersCompany.create(uc_params)
      end
    end

    respond_to do |format| 
      format.json {
        render json: {results: user.customer_companies }
      }
    end
  end

  def toggle_subscription_user_news_type
    user = current_resource_owner
    subscription_user = SubscriptionUser.where(subscription_id: params[:subscriptionId], user_id: user.id).first
    subscription_user_news_type = subscription_user.subscription_user_news_types.where(news_type_id: params[:newsTypeId]).first

    if params[:oldValue] == true
      subscription_user_news_type.destroy
    else
      record_params = { news_type_id: params[:newsTypeId], subscription_user: subscription_user }
      if SubscriptionUserNewsType.where(record_params).size > 0 # Delete any duplicates
        SubscriptionUserNewsType.where(record_params).each do |sunt|
          sunt.destroy
        end
      end
      subscription_user_news_type = SubscriptionUserNewsType.create(record_params)
    end

    respond_to do |format| 
      format.json {
        render json: {results: user.news_types_by_company }
      }
    end

  end

  def remove_notification
    if params[:notificationId]
      user = current_resource_owner
      Notification.find(params[:notificationId]).update_attribute(:date_read, Date.today)
    end
    respond_to do |format| 
      format.json {
        render json: {results: user.notifications_by_company }
      }
    end
  end
  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
