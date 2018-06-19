# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.
ssh_options = {
     user: 'ubuntu', # overrides user setting above
     keys: %w(/home/alvaador/.ssh/id_rsa_digitalocean_fgc),
     forward_agent: false,
     auth_methods: %w(publickey password)
}
require 'byebug'
role :app, %w{ubuntu@mpc-staging}
role :web, %w{ubuntu@mpc-staging}
role :db,  %w{ubuntu@mpc-staging}

set :branch, 'master'
server 'mpc-staging', user: 'ubuntu', roles: %w{web app}

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
#
# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

# server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value
# server 'cmshp', user: 'alvaador', roles: %w{web app}, port: 22022, ssh_options: ssh_options

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
set :ssh_options, ssh_options
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
