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

    @heading_title = @entity_name.pluralize
    respond_to do |format|
      format.html { render 'dashboard/users/index' }
      format.json { render json: UserDatatable.new(params, view_context: view_context, user: current_user ) }
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
    filtered_params = params.require(:user).permit(
      :id, 
      :first_name,
      :last_name,
      :username, 
      :password,
      :email, 
      :phone, 
      :avatar, 
      {:roles => []}, 
      :first_name, 
      :last_name, 
    )

    roles = []
    filtered_params[:roles].each do |role_id|
      if !role_id.nil? && role_id != '' && Role.find(role_id)
        roles << Role.find(role_id)
      end
    end
    filtered_params[:roles] = roles
    filtered_params
  end
end
