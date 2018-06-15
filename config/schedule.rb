set :output, "log/cron_log.log"
env :PATH, ENV['PATH']
every 4.minute do
  rake "cron:devices:check_live_status"
end
every 1.day, at: '11 pm' do
  rake "cron:advertising:compute_activity_levels"
end
every 1.day, at: '10:30 pm' do
  rake "cron:advertising:compute_campaign_statistics"
end
every '0 2 1 * *' do
  rake "cron:advertising:send_monthly_reports"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
