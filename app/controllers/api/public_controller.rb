class Api::PublicController < Api::ApplicationController

  before_action :doorkeeper_authorize!, except: [:register]

  def consultants
    respond_to do |format| 
      format.json {
        render json: {
          results: Subscription.where(company_id: params[:companyId]).map do |s|
            {
              id: s.user.id,
              firstName: s.user.first_name,
              lastName: s.user.last_name,
              suburb: s.user.address.suburb,
              state: s.user.address.state,
              country: s.user.address.country.name,
              # companies: s.user.subscribed_companies.map {|c| { id: c.id, name: c.name, label: c.label } }
            }
          end
        }
      }
    end
  end

  def register
    # TODO Validation
    user = User.create(
      username: params[:username],
      first_name: params[:firstName],
      last_name: params[:lastName],
      email: params[:username],
      password: params[:password],
    )
    country = Country.find_by_code(params[:countryCode])
    unless country.nil? || params[:timeZone].nil?
      user.address = Address.create(postcode: params[:postcode], country: country, timezone: params[:timeZone])
    end
    user.save!

    user = User.last
    access_token = Doorkeeper::AccessToken.create!(:resource_owner_id => user.id)
    render json: { access_token: Doorkeeper::OAuth::TokenResponse.new(access_token).body["access_token"] }
  end

  def update_profile
    user = current_resource_owner
    
    # TODO handle change of email address
    # TODO handle change of password
    #
    user.update_attributes(
      username: params[:username],
      first_name: params[:firstName],
      last_name: params[:lastName],
      email: params[:username],
      password: params[:password]
    )

    if user.address.nil?
      user.address = Address.create(
        street1: params[:street],
        postcode: params[:postcode],
        suburb: params[:suburb]
      )
    end

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
    news_items = []
    user.users_companies.find_by_company_id(params[:companyId]).consultant.subscriptions.each do |s| 
      s.news_items.where(active: true).each do |ni|
        news_items.push ni
      end
    end

    respond_to do |format| 
      format.json {
        render json: {results: news_items.map {|n| { 
          title: n.title,
          description: n.description,
          startDate: n.start_date,
          endDate: n.end_date,
          type: n.news_type.name,
          url: n.url,
          id: n.id,
          regularPrice: n.regularPrice,
          discountedPrice: n.discountedPrice
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
            countryCode: country_object[:code]
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

  def toggle_user_company_news_type
    user = current_resource_owner
    if params[:oldValue] == true
      if users_company = UsersCompany.where(user_id: user.id, company_id: params[:companyId]).first
        users_company.users_company_news_types.where(news_type_id: params[:newsTypeId]).first.destroy
      end
    else
      if users_company = UsersCompany.where(user_id: user.id, company_id: params[:companyId]).first 
        users_company.users_company_news_types.push UsersCompanyNewsType.create(news_type_id: params[:newsTypeId])
      end
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
