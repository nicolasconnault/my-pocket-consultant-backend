require "#{Rails.root}/lib/xhr"
class Dashboard::CompaniesController < Dashboard::ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @entity_name = 'Company'

    @categories = CompanyCategory.all.map {|cc| [cc.name, cc.id]}
    @news_types = NewsType.all.map {|nt| [nt.label, nt.id]}

    @heading_title = @entity_name.pluralize
    respond_to do |format|
      format.html { render 'dashboard/companies/index' }
      format.json { render json: CompanyDatatable.new(params, view_context: view_context, user: current_user ) }
    end
  end

  def edit
    @entity_name = 'Company'

    params = company_params

    if params[:id].blank?
      company = Company.new(params)
      if company.save
        flash[:success] = {"message" => "The company was successfully created.", "heading" => "Ready to roll!"}
      else
        flash[:error] = {"message" => "The company could not be created: #{company.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    else
      company = Company.find params[:id] 
      if company.update_attributes(params) 
        company.expire_second_level_cache
        flash[:success] = {"message" => "The company was successfully updated", "heading" => "Success!"}
      else
        flash[:error] = {"message" => "The company could not be updated: #{company.errors.full_messages.join(', ')}", "heading" => "Errors!"}
      end
    end 

    redirect_to companies_url
  end

  def create
    @errors = {}

    company = Company.new(company_params)
    
    if company.invalid?
      flash[:danger] = {"message" => "Something went wrong with the form, please check the form and try again", "heading" => "Error!"}
      @errors.reverse_merge!(company.errors.messages)
    else
      company.save
      Rails.cache.delete('companies/all')
      flash[:success] = {"message" => "The settings for this Company were successfully updated", "heading" => "Success!"}
    end 
    index
    render 'companies/index'
  end
  
  def company_params
    filtered_params = params.require(:company).permit(
      :id, 
      :name,
      :label,
      :company_category_id,
      {:news_types => []},
      :logo
    )
    news_types = []
    filtered_params[:news_types].each do |news_type_id|
      if !news_type_id.nil? && news_type_id != '' && NewsType.find(news_type_id)
        news_types << NewsType.find(news_type_id)
      end
    end
    filtered_params[:news_types] = news_types
    filtered_params[:name] = filtered_params[:label].parameterize
    filtered_params
  end
end
