require "#{Rails.root}/lib/xhr"
class Dashboard::CompanyCategoriesController < Dashboard::ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  load_and_authorize_resource

  @@model = CompanyCategory
  @@entity_name = 'Company Category'

  def index
    @entity_name = @@entity_name
    @heading_title = @@entity_name.pluralize
    respond_to do |format|
      format.html { render 'dashboard/company_categories/index' }
      format.json { render json: CompanyCategoryDatatable.new(params, view_context: view_context, user: current_user ) }
    end
  end

  def edit
    @entity_name = @@entity_name
    params = company_category_params

    if params[:id].blank?
      company_category = CompanyCategory.new(params)
      if company_category.save
        flash[:success] = {"message" => "The Company Category was successfully created.", "heading" => "Ready to roll!"}
      else
        flash[:error] = {"message" => "The Company Category could not be created: #{company_category.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    else
      company_category = CompanyCategory.find params[:id] 
      if company_category.update_attributes(params) 
        company_category.expire_second_level_cache
        flash[:success] = {"message" => "The Company Category was successfully updated", "heading" => "Success!"}
      else
        flash[:error] = {"message" => "The Company Category could not be updated: #{company_category.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    end 

    redirect_to company_categories_url
  end

  def create
    @errors = {}

    company_category = CompanyCategory.new(company_category_params)
    
    if company_category.invalid?
      flash[:danger] = {"message" => "Something went wrong with the form, please check the form and try again", "heading" => "Error!"}
      @errors.reverse_merge!(company_category.errors.messages)
    else
      company_category.save
      Rails.cache.delete('company_categories/all')
      flash[:success] = {"message" => "The settings for this Company Category were successfully updated", "heading" => "Success!"}
    end 
    index
    render 'company_categories/index'
  end
  
  def company_category_params
    filtered_params = params.require(:company_category).permit(
      :id, 
      :name,
      :label,
    )
    filtered_params[:name] = filtered_params[:label].parameterize
    filtered_params
  end
end
