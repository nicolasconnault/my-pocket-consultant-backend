class App::SubscriptionsController < Dashboard::ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  load_and_authorize_resource
 
  def index
    render 'app/subscriptions/index'
  end
end
