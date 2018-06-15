# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'dashboard'
set :repo_url, 'git@bitbucket-fgc:feelgreatchallenge/hp-dashboard.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/alvaador/rails_apps/dashboard'
set :stages, %w(production development)
set :default_stage, "production"
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.3.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads', 'public/cache-uploads')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :deploy do
#
#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end
#
# end

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
# The following 3 lines should work, but they don't, I get a big error message during deployment
# set :whenever_environment, ->{ fetch(:stage) }
# set :whenever_command, 'bundle exec whenever'
# require 'whenever/capistrano'
# Error:
# INFO [1cb76e6c] Running /usr/bin/env bundle exec whenever --update-crontab admin_production --set environment=production --roles=app,web,db as deploy@54.153.138.51
# DEBUG [1cb76e6c] Command: bundle exec whenever
# DEBUG [1cb76e6c] 	bash: bundle: command not found
# (Backtrace restricted to imported tasks)
# cap aborted!
# SSHKit::Runner::ExecuteError: Exception while executing as deploy@54.153.138.51: bundle exec whenever exit status: 127
# bundle exec whenever stdout: Nothing written
# bundle exec whenever stderr: bash: bundle: command not found
#
# SSHKit::Command::Failed: bundle exec whenever exit status: 127
# bundle exec whenever stdout: Nothing written
# bundle exec whenever stderr: bash: bundle: command not found
#
# Tasks: TOP => whenever:update_crontab
# (See full trace by running task with --trace)
# The deploy has failed with an error: Exception while executing as deploy@54.153.138.51: bundle exec whenever exit status: 127
# bundle exec whenever stdout: Nothing written
# bundle exec whenever stderr: bash: bundle: command not found

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end
