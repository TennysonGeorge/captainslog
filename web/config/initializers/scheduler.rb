return if defined?(Rails::Console) || Rails.env.test? || ARGV.first != "jobs:work"

puts "Initializing scheduler"

Concurrent::TimerTask.new(:execution_interval => 2.hours) do
  puts "scheduling ScheduleConnectionDataPullsJob"
  ScheduleConnectionDataPullsJob.perform_later
end.execute
