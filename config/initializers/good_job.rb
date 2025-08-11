# frozen_string_literal: true

# GoodJob configuration
# Minimal defaults; adjust as needed per environment.
Rails.application.configure do
  # In development keep job records for easier debugging
  config.good_job.preserve_job_records = true if Rails.env.development?

  # Use inline execution in test for deterministic specs (will set later in spec helper)
  # config.good_job.execution_mode = :inline if Rails.env.test?

  # Recommended queues: default only for now
  # config.good_job.queues = 'default'
end
