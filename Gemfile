source 'https://rubygems.org'
gem 'rails', '~> 5.0.2'
gem 'sass-rails', '~> 5.0'
gem 'activerecord-import', '>= 0.11.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'amoeba'
gem 'aws-sdk'
gem 'aws-sdk-rails'
gem 'bitmask_attributes'
gem 'bootstrap-sass',       '~>3.3.6'
gem 'bootstrap-validator-rails', '~> 0.5.3'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'
gem 'byebug'
gem 'cancancan'
gem 'capistrano'
gem 'capistrano-bundler'
gem 'capistrano-passenger'
gem 'capistrano-rails'
gem 'capistrano-rbenv', github: 'capistrano/rbenv'
gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'
gem 'chosen-rails'
gem 'coffee-rails', '~> 4.2'
gem 'config'
gem 'curb'
gem 'dalli'
gem 'devise', '~> 4.4.0'
gem 'doorkeeper'
gem 'execjs'
gem 'font-awesome-rails'
gem 'fullcalendar-rails'
gem 'garlicjs-rails'
gem 'geocoder'
gem 'gmaps4rails'
gem 'holidays'
gem 'htmlentities'
gem 'jbuilder'
gem 'multi_json'
gem 'jquery-datatables-rails', '~> 3.4.0'
gem 'ajax-datatables-rails', '~> 0.4.0'
gem 'jquery-minicolors-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery_bbq_rails'
gem 'jscrollpane-rails'
gem 'js-routes'
gem 'kaminari'
gem 'lightbox2-rails'
gem 'mandrill-api'
gem 'momentjs-rails', '>= 2.9.0'
gem 'carrierwave', '~> 1.0'
gem 'carrierwave-aws'
gem 'paperclip'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'record_tag_helper', '~> 1.0'
gem 'rack-cors', :require => 'rack/cors'
gem 'rails-push-notifications', '~> 0.2.0'
gem 'redis'
gem 'rolify'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'second_level_cache', '~> 2.3.0'
gem 'seed_dump'
# gem 'select2-rails'
gem 'sidekiq'
gem 'silencer'
gem 'simple_form'
gem 'simple_form_fancy_uploads'
gem 'simple-navigation'
gem 'switchery-rails'
gem 'therubyracer'
gem 'timezone', '~> 1.0'
gem 'turbolinks', '~> 5'
gem 'underscore-rails'
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false
gem 'wupee', '>= 2.0.0.beta'
gem 'yaml_db'

group :production do
  # App monitoring
  gem 'newrelic_rpm'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
