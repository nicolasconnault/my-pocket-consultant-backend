class Api::PublicController < Api::ApplicationController

  def consultants
    respond_to do |format| 
      format.json {
        render json: {
          results: User.joins(:roles).where('roles.id = ?', Role.find_by_name('consultant')).map do |u|
            {
              id: u.id,
              first_name: u.first_name,
              last_name: u.last_name,
              suburb: u.address.suburb,
              state: u.address.state,
              country: u.address.country.name,
              companies: u.subscribed_companies.map {|c| { id: c.id, name: c.name, label: c.label } }
            }
          end
        }
      }
    end
  end

  def tutorials
    result = {}
    
    Company.all.each do |company|
      result[company.label] ||= {}

      company.company_tutorials.each do |tutorial|
        result[company.label][tutorial.tutorial_category.title] ||= []

        tutorial_object = { id: tutorial.id, title: tutorial.title, steps: []} 
        tutorial.tutorial_steps.each do |step|

          tutorial_object[:steps].push ({
            id: step.id,
            title: step.title,
            description: step.description,
            video: step.video
          })
        end

        result[company.label][tutorial.tutorial_category.title].push tutorial_object
      end
    end

    respond_to do |format| 
      format.json {
        render json: {results: result }
      }
    end
  end
  
  def user_details
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: {results: { id: user.id, first_name: user.first_name, last_name: user.last_name } }
      }
    end
  end

  def customer_companies
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: {results: user.customer_companies }
      }
    end
  end

  def select_consultant
    user = current_resource_owner
    uc = UsersCompany.where(user_id: user.id, company_id: params[:companyId]).first
    uc.consultant_id = params[:consultantId]
    uc.save!
    render json: {results: user.customer_companies }

  end

  def toggle_company
    user = current_resource_owner
    if params[:oldValue] == true
      if uc = UsersCompany.where(user_id: user.id, company_id: params[:companyId]).first
        uc.update_attribute(:enabled, false)
      end
    else
      uc_params = { user_id: user.id, company_id: params[:companyId] }
      if uc = UsersCompany.where(uc_params).first
        uc_params['enabled'] = true
        uc.update(uc_params)
      else
        UsersCompany.create(uc_params)
      end
    end

    respond_to do |format| 
      format.json {
        render json: {results: user.customer_companies }
      }
    end
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

end
