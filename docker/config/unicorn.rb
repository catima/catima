# Set UNICORN_WORKERS environment variable
# This script sets the number of Unicorn workers
# based on the memory available to the Docker container.
unless ENV['UNICORN_WORKERS']
  workers_count = `sh unicorn_workers.sh`.strip
  ENV['UNICORN_WORKERS'] = workers_count unless workers_count.empty?
end

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
# For Docker/K8s, use environment variable or default to 2.
worker_processes Integer(ENV.fetch("UNICORN_WORKERS", 2))

# Working directory for the Rails application
working_directory "/var/www/catima"

# Listen on TCP port for Docker networking (nginx will proxy to this)
# Using 0.0.0.0 to allow connections from other containers
listen "0.0.0.0:3000", :tcp_nopush => true, :backlog => 64

# Timeout for killing workers (in seconds)
timeout Integer(ENV.fetch("UNICORN_TIMEOUT", 60))

# PID file location
pid "/var/www/catima/tmp/pids/unicorn.pid"

# Log to stdout/stderr for Docker (captured by supervisor/docker logs)
stderr_path "/dev/stderr"
stdout_path "/dev/stdout"

# combine Ruby 2.0.0+ with "preload_app true" for memory savings
preload_app true

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# while queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

# local variable to guard against running a hook multiple times
run_once = true

before_fork do |_server, _worker|
  # the following is highly recommended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # Occasionally, it may be necessary to run non-idempotent code in the
  # master before forking.  Keep in mind the above disconnect! example
  # is idempotent and does not need a guard.
  if run_once
    # do_something_once_here ...
    run_once = false # prevent from firing again
  end
end

after_fork do |_server, _worker|
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
