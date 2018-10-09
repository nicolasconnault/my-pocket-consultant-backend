set :output, "log/cron_log.log"
env :PATH, ENV['PATH']
every 1.day, at: '1 am' do
  rake "cron:push_notifications:send"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
