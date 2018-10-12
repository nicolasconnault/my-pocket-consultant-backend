require "#{Rails.root}/lib/xhr"
class Dashboard::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'dashboard/application'
  before_action :setPrepare
  before_action :current_ability
  before_action :load_navigation
  @@model = nil
  @@entity_name = ''

  def current_ability
    @current_ability ||= DashboardAbility.new(current_user)
  end

  def delete
    id = params[:id]
    ids = params[:ids]

    if id
      entity = @@model.where(id: id)
      if entity.empty?
        message = Xhr.build_message "#{@@entity_name} has already been deleted.", :warning, "#{@@entity_name} already deleted"
      else
        entity.first.destroy
        message = Xhr.build_message "#{@@entity_name} successfully deleted."
      end
    elsif ids
      @@model.where(id: ids).each do |e|
        e.destroy
      end
      message = Xhr.build_message "#{@@entity_name} successfully deleted."
    end
    render json: message, status: 200
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

  def load_navigation
    @navigation = []
    if user_signed_in?
      # @notifications = current_user.notifications.wanted.unread.ordered
      @notifications = []
      @navigation << { title: 'Reports', url: '/', controller: 'reports', icon: 'bar-chart', children: [
          #{ title: 'Store Usage', url: reports_stores_path, icon: 'tv', action: 'stores', ability: { name: :read, object: CmsStatistic } }
        ]
      } 
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
