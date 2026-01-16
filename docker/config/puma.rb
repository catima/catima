# frozen_string_literal: true

# Puma configuration for staging and production environments
# Optimized for Kubernetes deployments

# Set the working directory
directory '/var/www/catima'

# Bind to port 3000 on all interfaces (for Docker/K8s networking)
bind 'tcp://0.0.0.0:3000'

# Number of worker processes
# Calculate based on available resources
# Default to 2 workers if not specified
workers_count = ENV.fetch('WEB_CONCURRENCY') do
  # Try to auto-calculate based on CPU/memory if helpers are available
  if File.exist?(File.join(__dir__, 'puma_helpers.rb'))
    require_relative 'puma_helpers'
    PumaHelpers.calculate_workers
  else
    2
  end
end.to_i

workers workers_count

# Number of threads per worker
# Puma threads handle concurrent requests within each worker
# For CPU-bound Rails apps, 5 threads per worker is a good starting point
# For I/O-bound apps, you can increase this
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

# Preload the application before forking workers
# This reduces memory usage via copy-on-write
preload_app!

# PID file location
pidfile '/var/www/catima/tmp/pids/puma.pid'

# State file for restarts
state_path '/var/www/catima/tmp/pids/puma.state'

# Logging
stdout_redirect '/dev/stdout', '/dev/stderr', true

# Worker timeout (in seconds)
# Kill and restart workers that take longer than this to respond
worker_timeout Integer(ENV.fetch('PUMA_WORKER_TIMEOUT', '60'))

# Disconnect database before forking workers
before_fork do
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord)
end

# Reconnect database after forking workers
before_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Graceful shutdown
before_worker_shutdown do
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord)
end

# Allow puma to be restarted by touch tmp/restart.txt
plugin :tmp_restart

# Enable worker killer plugin to prevent memory bloat (optional)
# Uncomment if you install the puma_worker_killer gem
# before_fork do
#   require 'puma_worker_killer'
#   PumaWorkerKiller.enable_rolling_restart
# end
