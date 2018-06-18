class App::PublicController < App::ApplicationController
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

  def customer_companies
    user = current_user || User.first # Delete this before going live, it's just to bypass initial authentication during testing
    respond_to do |format| 
      format.json {
        render json: {results: user.customer_companies }
      }
    end
  end

  def select_consultant
    user = current_user || User.first # Delete this before going live, it's just to bypass initial authentication during testing
    uc = UsersCompany.where(user_id: user.id, company_id: params[:companyId]).first
    uc.consultant_id = params[:consultantId]
    uc.save!
    render json: {results: user.customer_companies }

  end

  def toggle_company
    user = current_user || User.first # Delete this before going live, it's just to bypass initial authentication during testing
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
end
