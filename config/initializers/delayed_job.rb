require 'delayed_job'

Delayed::Worker.backend = :active_record

# Delayed::Job.destroy_failed_jobs = false
# silence_warnings do
#   Delayed::Job.const_set("MAX_ATTEMPTS", 5)
#   Delayed::Job.const_set("MAX_RUN_TIME", 5.minutes)
# end

# Start delayed jobs
if RAILS_ENV != 'development'
  "cd #{Rails.root} && script/worker start"
end