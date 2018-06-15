class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :setPrepare

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

  def current_ability
    current_user.ability
  end
end
