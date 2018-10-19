class Api::AuthController < Api::ApplicationController

  before_action :doorkeeper_authorize!, except: [:register]

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

  def resend_email_confirmation
    user = current_resource_owner
    begin
      user.resend_confirmation_instructions
    rescue OpenSSL::SSL::SSLError
      if Rails.env.production?
        # Handle error appropriately
      else 
        # Ignore error
      end
    end
    render json: { email: user.unconfirmed_email }, status: 200
  end

  # PIN should have already been confirmed in the App, this method is only meant to record the confirmation in the DB using Devise fields
  def email_confirmation
    user = current_resource_owner
    user.email = user.unconfirmed_email
    user.unconfirmed_email = nil
    user.confirmed_at = Time.now
  end


end
