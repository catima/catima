# frozen_string_literal: true

# Helper methods for Unicorn configuration
module UnicornHelpers
  module_function

  # Fetch ENV variable with proper handling of empty strings
  # since we cannot use .present? in this context
  def fetch_env(key, default)
    value = ENV[key]
    (value.nil? || value.strip.empty?) ? default : value
  end

  # Calculate the number of Unicorn workers based on available memory
  def calculate_workers
    worker_mb = Integer(fetch_env('UNICORN_WORKER_MB', '300'))
    reserved_mb = Integer(fetch_env('UNICORN_RESERVED_MB', '400'))

    # Detect cgroup version and read memory limit
    limit_bytes = read_memory_limit

    # Set a default value if the memory is unlimited or not available
    # Using 2^63 - 1 which is the actual MAX_INT64 value used by cgroups for "unlimited"
    if limit_bytes == 'max' || limit_bytes.to_i >= (2**63 - 1)
      return Integer(fetch_env('UNICORN_WORKERS', '2'))
    end

    limit_mb = limit_bytes.to_i / 1024 / 1024
    available_mb = limit_mb - reserved_mb

    workers = available_mb / worker_mb
    workers < 1 ? 1 : workers
  end

  # Read memory limit from cgroup files
  def read_memory_limit
    if File.exist?('/sys/fs/cgroup/memory.max')
      File.read('/sys/fs/cgroup/memory.max').strip
    elsif File.exist?('/sys/fs/cgroup/memory/memory.limit_in_bytes')
      File.read('/sys/fs/cgroup/memory/memory.limit_in_bytes').strip
    else
      'max'
    end
  end
end
