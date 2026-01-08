# frozen_string_literal: true

# Calculate the number of Unicorn workers based on available memory
module UnicornWorkers
  module_function

  def calculate
    worker_mb = ENV["UNICORN_WORKER_MB"].present? ? Integer(ENV["UNICORN_WORKER_MB"]) : 300
    reserved_mb = ENV["UNICORN_RESERVED_MB"].present? ? Integer(ENV["UNICORN_RESERVED_MB"]) : 400

    # Detect cgroup version and read memory limit
    limit_bytes = read_memory_limit

    # Set a default value if the memory is unlimited or not available
    if limit_bytes == 'max' || limit_bytes.to_i >= (2**63 - 1)
      return ENV["UNICORN_WORKERS"].present? ? Integer(ENV["UNICORN_WORKERS"]) : 2
    end

    limit_mb = limit_bytes.to_i / 1024 / 1024
    available_mb = limit_mb - reserved_mb

    workers = available_mb / worker_mb
    workers < 1 ? 1 : workers
  end

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
