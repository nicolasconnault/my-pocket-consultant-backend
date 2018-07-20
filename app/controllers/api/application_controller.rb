class Api::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, prepend: true
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_resource_owner, if: :devise_controller?  

  respond_to :json 
  before_action :setPrepare
  before_action :current_ability

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def setPrepare
    class << ActiveRecord::Base
      def _prepare(sql, params)
        params.each do |i|
          case true
          when i.instance_of?(String)
              i = "'#{i}'"
          when i.instance_of?(Numeric)
              i = i.to_s
          when i.nil?
              i = "NULL"
          end
          sql = sql.sub(/\?/, i.to_s)
        end
        sql
      end
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      flash[:warning] = {"message" => exception.message, "heading" => "Access Denied"}
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to dashboard_root_url }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end
  
  protected
  
  # Devise methods
  # Authentication key(:username) and password field will be added automatically by devise.
  def configure_permitted_parameters
    added_attrs = [:email, :first_name, :last_name]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  # Doorkeeper methods
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
