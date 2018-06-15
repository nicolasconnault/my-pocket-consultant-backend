require "#{Rails.root}/lib/xhr"
class Dashboard::UsersController < Dashboard::ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:sso]
  load_and_authorize_resource except: [:sso]

  def index
    @entity_name = 'User'
    @roles = Role.all.map {|role| [role.name, role.id]}
    @group_name = (params[:owner_id] && params[:owner_type] == 'Group') ? Group.find(params[:owner_id]).name : nil
    @store_name = (params[:owner_id] && params[:owner_type] == 'Store') ? Store.find(params[:owner_id]).name : nil
    @device_name = (params[:owner_id] && params[:owner_type] == 'Device') ? Device.find(params[:owner_id]).name : nil
    
    @stores = Store.joins(address: :country).where("countries.code = 'AU'").order(:name).map {|store| [store.name, store.id]}
    @groups = Group.joins(address: :country).where("countries.code = 'AU'").order(:name).map {|g| [g.name, g.id] }
    @advertisers = Advertiser.all.order(:name).map {|a| [a.name, a.id] }

    @heading_title = @entity_name.pluralize
    if @device_name
      @heading_title = "#{@device_name} #{@heading_title}"
    end
    if @store_name
      @heading_title = "#{@store_name} #{@heading_title}"
    end
    if @group_name
      @heading_title = "#{@group_name} #{@heading_title}"
    end

    respond_to do |format|
      format.html { render 'dashboard/users/index' }
      format.json { render json: UserDatatable.new(view_context, {user: current_user, owner_id: params[:owner_id], owner_type: params[:owner_type]}) }
    end
  end

  def check_username_uniqueness 
    render json: {valid: User.where(username: params[:username]).where('id <> ?', [params[:id]]).count == 0}, status: 200
  end

  def check_email_uniqueness
    render json: {valid: User.where(email: params[:email]).where('id <> ?', [params[:id]]).count == 0}, status: 200
  end

  def edit
    @entity_name = 'User'

    params = user_params
    
    if params[:email] == ''
      params.delete 'email'
    end
    
    if params[:password] == ''
      params.delete 'password'
    end

    if params[:id].blank?
      user = User.new(params)
      if user.save
        flash[:success] = {"message" => "The user account was successfully created.", "heading" => "Ready to roll!"}
      else
        flash[:error] = {"message" => "The user account could not be created: #{user.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    else
      user = User.find params[:id] 
      if user.update_attributes(params) 
        user.expire_second_level_cache
        flash[:success] = {"message" => "The user account was successfully updated", "heading" => "Success!"}
      else
        flash[:error] = {"message" => "The user account could not be updated: #{user.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    end 

    redirect_to dashboard_users_url
  end

  def create
    user_type = params[:user_type]

    @errors = {}
    if user_type == 'kiosk' && params[:kiosk_id].nil?
      @errors[:kiosk_id] = "You must select a Kiosk if this user is a Pharmacy Kiosk" 
      # TODO Also set up this user with all stuff ready for Healthpoint Live
    elsif user_type == 'config' && params[:config_id].nil?
      @errors[:config_id] = "You must select a Pharmacy Group if this user is a Pharmacy Group" 
    end 

    user = User.new(user_params)
    
    if user.invalid?
      flash[:danger] = {"message" => "Something went wrong with the form, please check the form and try again", "heading" => "Error!"}
      @errors.reverse_merge!(user.errors.messages)
    else
      user.save
      Rails.cache.delete('users/all')
      flash[:success] = {"message" => "The settings for this User were successfully updated", "heading" => "Success!"}
    end 
    index
    render 'users/index'
  end
  
  def user_params
    filtered_params = params.require(:user).permit(:username, :email, :id, :wake_on_schedule, :customer_type, :avatar, :owner_type, :owner_id, {:roles => []}, :first_name, :last_name, :password)

    roles = []
    filtered_params[:roles].each do |role_id|
      if !role_id.nil? && role_id != '' && Role.find(role_id)
        roles << Role.find(role_id)
      end
    end
    filtered_params[:roles] = roles
    filtered_params
  end

  def sso
    device = Device.find params[:device_id]
    if Digest::MD5.hexdigest(device.registration_code) == params[:registration_code_md5]
      # Make sure this user has the store manager role
      if device.users.blank?
        device.users << User.create
      end
      user = device.users.first

      if !user.has_role? 'device_manager'
        user.roles << Role.find_by_name('device_manager')
      end

      sign_in user

      redirect_to Settings.urls.dashboard
    else
      redirect_to Settings.urls.frontend
    end
  end
end
