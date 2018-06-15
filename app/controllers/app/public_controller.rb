class App::PublicController < App::ApplicationController
  def companies_with_consultants
    user = current_user || User.first # Delete this before going live, it's just to bypass initial authentication during testing
    respond_to do |format| 
      format.json {
        render json: {results: user.companies_with_consultants}
      }
    end
  end
end
