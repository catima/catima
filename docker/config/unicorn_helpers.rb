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

  # Calculate the number of Unicorn workers based on available memory AND CPU
  # We take the MINIMUM between memory-based and CPU-based calculations
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

    # Calculate workers based on available memory
    limit_mb = limit_bytes.to_i / 1024 / 1024
    available_mb = limit_mb - reserved_mb
    memory_based_workers = available_mb / worker_mb
    memory_based_workers = 1 if memory_based_workers < 1

    # Calculate workers based on available CPU
    cpu_limit = read_cpu_limit
    cpu_based_workers = cpu_limit > 0 ? cpu_limit : memory_based_workers

    # Never use more workers than available CPUs
    [memory_based_workers, cpu_based_workers].min
  end

  # Read memory limit from cgroup files
  # Returns 'max' if unlimited or unable to determine
  def read_memory_limit
    if File.exist?('/sys/fs/cgroup/memory.max')
      File.read('/sys/fs/cgroup/memory.max').strip
    elsif File.exist?('/sys/fs/cgroup/memory/memory.limit_in_bytes')
      File.read('/sys/fs/cgroup/memory/memory.limit_in_bytes').strip
    else
      'max'
    end
  end

  # Read CPU limit from cgroup files and return number of CPUs
  # Returns 0 if unlimited or unable to determine
  def read_cpu_limit
    # Try cgroup v2 first (cpu.max format: "quota period")
    if File.exist?('/sys/fs/cgroup/cpu.max')
      cpu_max = File.read('/sys/fs/cgroup/cpu.max').strip
      quota, period = cpu_max.split

      # "max" means unlimited
      return 0 if quota == 'max'

      # Calculate number of CPUs: quota / period
      # Example: "200000 100000" = 200ms / 100ms = 2 CPUs
      return (quota.to_f / period.to_f).ceil if period.to_i > 0
    end

    # Try cgroup v1 (separate quota and period files)
    if File.exist?('/sys/fs/cgroup/cpu/cpu.cfs_quota_us') &&
       File.exist?('/sys/fs/cgroup/cpu/cpu.cfs_period_us')
      quota = File.read('/sys/fs/cgroup/cpu/cpu.cfs_quota_us').strip.to_i
      period = File.read('/sys/fs/cgroup/cpu/cpu.cfs_period_us').strip.to_i

      # -1 means unlimited in cgroup v1
      return 0 if quota == -1 || period == 0

      # Calculate number of CPUs
      return (quota.to_f / period.to_f).ceil
    end

    # Unable to determine CPU limit, return 0
    # (will fallback to memory-based calculation)
    0
  end
end
