require 'domain_constraint'

Rails.application.routes.draw do
  use_doorkeeper
  mount Wupee::Engine, at: "/wupee"
  devise_for :users, controllers: { sessions: 'users/sessions' }

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
 
  scope module: 'dashboard' do
    constraints DomainConstraint.new(['dashboard.mypocketconsultant.app', 'stagingdashboard.mypocketconsultant.app', 'dashboard.mypocketconsultant', 'mpcdashboard.smbstreamline.com.au']) do
      
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

  scope module: 'api' do
    constraints DomainConstraint.new(['api.mypocketconsultant.app', 'stagingapi.mypocketconsultant.app', 'app.mypocketconsultant', 'mpc.smbstreamline.com.au', '192.168.0.11']) do
      use_doorkeeper do
        # No need to register client application
        skip_controllers :applications, :authorized_applications
      end

      root 'home#index', as: :app_root
      scope 'customer', defaults: { format: :json } do
        post '/company_news_items' => 'customer#company_news_items', as: :company_news_items
        post '/news_types' => 'customer#news_types', as: :news_types
        post '/notifications' => 'customer#notifications', as: :user_notifications
        post '/register' => 'customer#register', as: :register
        post '/user' => 'customer#user_details', as: :user_details
        post '/consultants' => 'customer#consultants', as: :consultants
        post '/customer_companies' => 'customer#customer_companies', as: :customer_companies
        post '/tutorials' => 'customer#tutorials', as: :tutorials

        put '/save_profile' => 'customer#save_profile', as: :save_profile
        put '/toggle_company' => 'customer#toggle_company', as: :toggle_company
        put '/select_consultant' => 'customer#select_consultant', as: :select_consultant
        put '/toggle_user_company_news_type' => 'customer#toggle_subscription_user_news_type', as: :toggle_subscription_user_news_type

        delete '/remove_notification' => 'customer#remove_notification', as: :remove_notification

        devise_for :users, controllers: {
           registrations: 'api/customer/registrations',
        }, skip: [:sessions, :password]

      end

      scope 'consultant', defaults: { format: :json } do 
        post '/subscribed_companies' => 'consultant#subscribed_companies', as: :subscribed_companies
        post '/category_companies' => 'consultant#category_companies', as: :category_companies

        post '/call_reminders' => 'consultant#call_reminders', as: :call_reminders
        put '/create_call_reminder' => 'consultant#create_call_reminder', as: :create_call_reminder

        put '/create_customer_note' => 'consultant#create_customer_note', as: :create_customer_note
        put '/update_customer_note' => 'consultant#update_customer_note', as: :update_customer_note
        delete '/remove_customer_note' => 'consultant#remove_customer_note', as: :remove_customer_note
        
        put '/create_news_item' => 'consultant#create_news_item', as: :create_news_item
        put '/update_news_item' => 'consultant#update_news_item', as: :update_news_item
        delete '/remove_news_item' => 'consultant#remove_news_item', as: :remove_news_item
        put '/toggle_news_item' => 'consultant#toggle_news_item', as: :toggle_news_item
        post '/upload_image/:news_item_id' => 'consultant#upload_image', as: :upload_image
        post '/upload_image_for_new_news_item/:subscription_id' => 'consultant#upload_image_for_new_news_item', as: :upload_image_for_new_news_item 
      end
    end
  end
end
