require 'domain_constraint'

Rails.application.routes.draw do
  mount Wupee::Engine, at: "/wupee"
  devise_for :users, controllers: { sessions: 'users/sessions' }

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
 
  scope module: 'dashboard' do
    constraints DomainConstraint.new(['dashboard.mypocketconsultant.com', 'stagingdashboard.mypocketconsultant.com', 'dashboard.mypocketconsultant']) do
      
      root 'home#index', as: :dashboard_root
      get '/' => 'home#index', as: :dashboard_home
      post 'home/filter' => 'home#filter', as: :dashboard_home_filter
      get 'preferences' => 'preferences#index', as: :dashboard_preferences

      scope :account, defaults: { format: :json } do
        resources :notifications, only: [:index, :show] do
          patch :mark_as_read, on: :member
          patch :mark_all_as_read, on: :collection
        end
        get 'all_notifications' => 'notifications#all', as: :all_notifications
        get 'clear_notifications' => 'notifications#mark_all_as_read', as: :clear_notifications
      end

      scope 'admin' do
        scope 'users' do 
          match '/(:owner_type/:owner_id)'    => 'users#index',   as: :dashboard_users, via: [:get, :post], constraints: {owner_id: /[0-9]+/}
          get '/check_username_uniqueness'    => 'users#check_username_uniqueness',   as: :check_username_uniqueness
          get '/check_email_uniqueness'    => 'users#check_email_uniqueness',   as: :check_email_uniqueness
          get '/sso/:device_id/:registration_code_md5' => 'users#sso', as: :user_sso
          post '/edit'   => 'users#edit',    as: :dashboard_users_create
          put '/edit'   => 'users#edit',    as: :dashboard_users_edit
          delete '/' => 'users#delete',  as: :dashboard_users_delete 
        end
      end
    end
  end

  scope module: 'app' do
    constraints DomainConstraint.new(['app.mypocketconsultant.com', 'stagingapp.mypocketconsultant.com', 'app.mypocketconsultant', '192.168.0.11']) do
      
      root 'home#index', as: :app_root
      scope 'customer', defaults: { format: :json } do
        get '/companies_with_consultants' => 'public#companies_with_consultants', as: :companies_with_consultants
      end
    end
  end
end
