require "#{Rails.root}/lib/xhr"
class Dashboard::NewsTypesController < Dashboard::ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  load_and_authorize_resource
  
  MODEL = NewsType
  ENTITY_NAME = 'News Type'

  def index
    @entity_name = ENTITY_NAME

    @heading_title = @entity_name.pluralize
    respond_to do |format|
      format.html { render 'dashboard/news_types/index' }
      format.json { render json: NewsTypeDatatable.new(params, view_context: view_context, user: current_user ) }
    end
  end

  def edit
    @entity_name = ENTITY_NAME

    params = news_type_params

    if params[:id].blank?
      news_type = NewsType.new(params)
      if news_type.save
        flash[:success] = {"message" => "The news type was successfully created.", "heading" => "Ready to roll!"}
      else
        flash[:error] = {"message" => "The news type could not be created: #{news_type.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    else
      news_type = NewsType.find params[:id] 
      if news_type.update_attributes(params) 
        news_type.expire_second_level_cache
        flash[:success] = {"message" => "The news type was successfully updated", "heading" => "Success!"}
      else
        flash[:error] = {"message" => "The news type could not be updated: #{news_type.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    end 

    redirect_to admin_news_types_url
  end

  def create
    @errors = {}

    news_type = NewsType.new(news_type_params)
    
    if news_type.invalid?
      flash[:danger] = {"message" => "Something went wrong with the form, please check the form and try again", "heading" => "Error!"}
      @errors.reverse_merge!(news_type.errors.messages)
    else
      news_type.save
      Rails.cache.delete('news_types/all')
      flash[:success] = {"message" => "The settings for this News Type were successfully updated", "heading" => "Success!"}
    end 
    index
    render 'news_types/index'
  end
  
  def news_type_params
    filtered_params = params.require(:news_type).permit(
      :id, 
      :name,
      :label,
    )
    filtered_params[:name] = filtered_params[:label].parameterize
    filtered_params
  end
end
