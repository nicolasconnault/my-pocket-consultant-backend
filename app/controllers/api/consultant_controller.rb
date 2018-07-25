class Api::ConsultantController < Api::ApplicationController

  before_action :doorkeeper_authorize!, except: [:register]

  def save_profile
    user = current_resource_owner
    
    # TODO handle change of email address
    # TODO handle change of password
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

  def subscribed_companies
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: { 
          results: user.subscriptions.map do |s| 
            {
              id: s.id,
              companyName: s.company.name, 
              companyLabel: s.company.label, 
              companyId: s.company.id,
              customerCount: s.customers.count,
              active: s.active,
              websiteUrl: s.website_url,
              facebookUrl: s.facebook_url,
              twitterUrl: s.twitter_url
            }
          end
        }
      }
    end
  end
  
  def category_companies
    respond_to do |format| 
      format.json {
        render json: { 
          results: Company.joins(:company_category).group_by(&:company_category_label)
        }
      }
    end
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
