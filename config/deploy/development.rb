# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.
ENV["AWS_REGION"] = 'ap-southeast-2'

ssh_options = {
     user: 'ubuntu', # overrides user setting above
     keys: %w(/home/alvaador/.ssh/id_rsa_digitalocean_fgc),
     forward_agent: false,
     auth_methods: %w(publickey password)
}
set :deploy_to, '/home/ubuntu/rails_apps/hp2'
require 'byebug'
role :app, %w{ubuntu@mpc-staging}
role :web, %w{ubuntu@mpc-staging}
role :db,  %w{ubuntu@mpc-staging}

set :branch, 'master'

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

#server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value
#server 'connault.com.au', user: 'deploy', roles: %w{web app}

set :ssh_options, ssh_options

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
#
#namespace :db do
#  desc "Create database yaml in shared path"
#  task :configure do
#    set :database_username do
#      "tfgc"
#    end
#
#    set :database_password do
#      Capistrano::CLI.password_prompt "Database Password: "
#    end
#
#    db_config = <<-EOF
#      base: &base
#        adapter: postgresql
#        encoding: utf8
#        reconnect: false
#        pool: 5
#        username: #{database_username}
#        password: #{database_password}
#      development:
#        database: #{application}_development
#        <<: *base
#      test:
#        database: #{application}_test
#        <<: *base
#      production:
#        database: #{application}_production
#        <<: *base
#    EOF
#
#    run "mkdir -p #{shared_path}/config"
#    put db_config, "#{shared_path}/config/database.yml"
#  end
#
#  desc "Make symlink for database yaml"
#  task :symlink do
#    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
#  end
#end
