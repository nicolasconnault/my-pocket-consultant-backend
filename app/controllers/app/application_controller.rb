class App::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
end
