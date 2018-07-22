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
          results: user.subscribed_companies.map do |c| 
            {
              name: c.name, 
              label: c.label, 
              id: c.id 
            }
          end
        }
      }
    end
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
