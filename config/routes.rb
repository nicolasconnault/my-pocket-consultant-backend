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
          match '/'    => 'users#index',   as: :users, via: [:get, :post], constraints: {owner_id: /[0-9]+/}
          get '/check_username_uniqueness'    => 'users#check_username_uniqueness',   as: :check_username_uniqueness
          get '/check_email_uniqueness'    => 'users#check_email_uniqueness',   as: :check_email_uniqueness
          post '/edit'   => 'users#edit',    as: :users_create
          put '/edit'   => 'users#edit',    as: :users_edit
          delete '/' => 'users#delete',  as: :users_delete 
        end
        scope 'companies' do
          match '/' => 'companies#index', as: :companies, via: [:get, :post]
          post '/edit'   => 'companies#edit',    as: :companies_create
          put '/edit'   => 'companies#edit',    as: :companies_edit
          delete '/' => 'companies#delete',  as: :companies_delete 
        end
        scope 'company_categories' do
          match '/' => 'company_categories#index', as: :company_categories, via: [:get, :post]
          post '/edit'   => 'company_categories#edit',    as: :company_categories_create
          put '/edit'   => 'company_categories#edit',    as: :company_categories_edit
          delete '/' => 'company_categories#delete',  as: :company_categories_delete 
        end
        scope 'tutorials' do
          match '/' => 'tutorials#index', as: :company_tutorials, via: [:get, :post]
          post '/edit'   => 'tutorials#edit',    as: :company_tutorials_create
          put '/edit'   => 'tutorials#edit',    as: :company_tutorials_edit
          delete '/' => 'tutorials#delete',  as: :company_tutorials_delete 
        end
        scope 'tutorial_categories' do
          match '/' => 'tutorial_categories#index', as: :tutorial_categories, via: [:get, :post]
          post '/edit'   => 'tutorial_categories#edit',    as: :tutorial_categories_create
          put '/edit'   => 'tutorial_categories#edit',    as: :tutorial_categories_edit
          delete '/' => 'tutorial_categories#delete',  as: :tutorial_categories_delete 
        end
        scope 'news_types' do
          match '/' => 'news_types#index', as: :admin_news_types, via: [:get, :post]
          post '/edit'   => 'news_types#edit',    as: :news_types_create
          put '/edit'   => 'news_types#edit',    as: :news_types_edit
          delete '/' => 'news_types#delete',  as: :news_types_delete 
        end
      end

      scope 'consultant' do
        scope 'subscriptions' do
          match '/' => 'subscriptions#index', as: :subscriptions, via: [:get, :post]
          post '/edit'   => 'subscriptions#edit',    as: :subscriptions_create
          put '/edit'   => 'subscriptions#edit',    as: :subscriptions_edit
          delete '/' => 'subscriptions#delete',  as: :subscriptions_delete
        end

        scope 'billing' do
          get '/' => 'billing#index', as: :billing
        end
      end
    end
  end

  scope module: 'app' do
    constraints DomainConstraint.new(['subs.mypocketconsultant.app', 'stagingapi.mypocketconsultant.app', 'subs.mypocketconsultant', 'subs.smbstreamline.com.au', '192.168.0.11']) do
      use_doorkeeper do
        # No need to register client application
        skip_controllers :applications, :authorized_applications
      end

      root 'subscriptions#index', as: :app_root
      get 'subscriptions/:token' => 'subscriptions#index', as: :subscriptions_index
    end
  end

  scope module: 'api' do
    constraints DomainConstraint.new(['api.mypocketconsultant.app', 'stagingapi.mypocketconsultant.app', 'app.mypocketconsultant', 'mpc.smbstreamline.com.au', '192.168.0.11']) do
      use_doorkeeper do
        # No need to register client application
        skip_controllers :applications, :authorized_applications
      end

      root 'home#index', as: :api_root

      scope 'push_notification', defaults: { format: :json } do
        post '/save_push_token' => 'push_notification#save_push_token', as: :save_push_token

      end

      scope 'auth', defaults: { format: :json } do
        post '/register' => 'auth#register', as: :register
        post '/email_confirmation' => 'auth#email_confirmation', as: :email_confirmation
        post '/resend_email_confirmation' => 'auth#resend_email_confirmation', as: :resend_email_confirmation
        devise_for :users, controllers: {
           registrations: 'api/auth/registrations',
        }, skip: [:sessions, :password]

      end

      scope 'customer', defaults: { format: :json } do
        post '/company_news_items' => 'customer#company_news_items', as: :company_news_items
        post '/news_types' => 'customer#news_types', as: :news_types
        post '/notifications' => 'customer#notifications', as: :user_notifications
        post '/user' => 'customer#user_details', as: :user_details
        post '/consultants' => 'customer#consultants', as: :consultants
        post '/customer_companies' => 'customer#customer_companies', as: :customer_companies
        post '/tutorials' => 'customer#tutorials', as: :tutorials

        put '/save_profile' => 'customer#save_profile', as: :save_profile
        put '/toggle_company' => 'customer#toggle_company', as: :toggle_company
        put '/select_consultant' => 'customer#select_consultant', as: :select_consultant
        put '/toggle_user_company_news_type' => 'customer#toggle_subscription_user_news_type', as: :toggle_subscription_user_news_type

        delete '/remove_notification' => 'customer#remove_notification', as: :remove_notification

      end

      scope 'consultant', defaults: { format: :json } do 
        post '/subscribed_companies' => 'consultant#subscribed_companies', as: :subscribed_companies
        post '/category_companies' => 'consultant#category_companies', as: :category_companies

        post '/call_reminders' => 'consultant#call_reminders', as: :call_reminders
        put '/create_call_reminder' => 'consultant#create_call_reminder', as: :create_call_reminder

        put '/create_customer_note' => 'consultant#create_customer_note', as: :create_customer_note
        put '/update_customer_note' => 'consultant#update_customer_note', as: :update_customer_note
        delete '/remove_customer_note' => 'consultant#remove_customer_note', as: :remove_customer_note
        
        put '/create_subscription' => 'consultant#create_subscription', as: :create_subscription
        put '/update_subscription' => 'consultant#update_subscription', as: :update_subscription
        put '/save_subscription_token' => 'consultant#save_subscription_token', as: :save_subscription_token
        delete '/remove_subscription' => 'consultant#remove_subscription', as: :remove_subscription
        put '/deactivate_subscription'   => 'consultant#deactivate_subscription',    as: :deactivate_subscription
        
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
