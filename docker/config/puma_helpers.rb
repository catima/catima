# frozen_string_literal: true

# Helper methods for Puma configuration
module PumaHelpers
  module_function

  # Fetch ENV variable with proper handling of empty strings
  # since we cannot use .present? in this context
  def fetch_env(key, default)
    value = ENV[key]
    value.nil? || value.strip.empty? ? default : value
  end

  # Calculate the number of Puma workers based on available memory AND CPU
  # Takes into account Puma's multi-threaded nature
  #
  # Puma model: N workers × M threads = total capacity
  # Memory model: master process + (N workers × incremental memory)
  #
  # Strategy:
  # 1. Calculate optimal thread count based on CPU and I/O-bound factor
  # 2. Calculate max workers based on available memory
  # 3. Derive workers = min(threads_total / threads_per_worker, max_workers_by_memory)
  # 4. Ensure minimum of 2 workers for redundancy
  def calculate_workers
    threads_per_worker = Integer(fetch_env('RAILS_MAX_THREADS', '5'))

    # Calculate optimal total threads based on CPU availability
    cpu_limit = read_cpu_limit
    total_threads = calculate_total_threads(cpu_limit, threads_per_worker)

    # Calculate max workers based on available memory
    max_workers_by_memory = calculate_max_workers_by_memory

    # Calculate optimal workers from thread count
    # Minimum of 2 workers for redundancy (unless memory constrained)
    optimal_workers = [total_threads / threads_per_worker, 2].max

    # Return minimum between optimal and memory-constrained
    [optimal_workers, max_workers_by_memory].min
  end

  # Calculate total threads based on CPU limit and application I/O profile
  # Rails apps are typically I/O-bound (DB, cache, API calls)
  # Can handle more threads than CPU cores due to waiting time
  def calculate_total_threads(cpu_limit, threads_per_worker)
    if cpu_limit > 0
      # I/O-bound factor: how many threads per CPU core
      # 3.0 = good for typical Rails apps with DB/API calls
      # 2.0 = for more CPU-intensive apps
      # 5.0 = for very I/O-heavy apps
      io_bound_factor = Float(fetch_env('PUMA_IO_FACTOR', '3.0'))

      # Calculate total threads: CPUs × I/O factor
      (cpu_limit * io_bound_factor).to_i
    else
      # No CPU limit detected, use conservative default
      # 2 workers × threads_per_worker
      2 * threads_per_worker
    end
  end

  # Calculate maximum workers based on available memory
  # Puma memory model: master + (workers × incremental_memory)
  # Unlike Unicorn, workers share master's code via copy-on-write
  def calculate_max_workers_by_memory
    limit_bytes = read_memory_limit

    # If memory is unlimited or not detectable, return generous limit
    if limit_bytes == 'max' || limit_bytes.to_i >= ((2**63) - 1)
      return 8 # Reasonable upper limit
    end

    # Memory configuration for Puma
    master_mb = Integer(fetch_env('PUMA_MASTER_MB', '200'))
    worker_increment_mb = Integer(fetch_env('PUMA_WORKER_MB', '360'))
    reserved_mb = Integer(fetch_env('PUMA_RESERVED_MB', '400'))

    # Calculate available memory for workers
    limit_mb = limit_bytes.to_i / 1024 / 1024
    available_mb = limit_mb - reserved_mb - master_mb

    # Ensure we have enough memory for at least 1 worker
    return 1 if available_mb < worker_increment_mb

    # Calculate max workers: (available - master) / worker_increment
    max_workers = available_mb / worker_increment_mb

    # Cap at reasonable maximum (too many workers = overhead)
    [max_workers, 8].min
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
      return (quota.to_f / period.to_i).ceil if period.to_i > 0
    end

    # Try cgroup v1 (separate quota and period files)
    if File.exist?('/sys/fs/cgroup/cpu/cpu.cfs_quota_us') &&
       File.exist?('/sys/fs/cgroup/cpu/cpu.cfs_period_us')
      quota = File.read('/sys/fs/cgroup/cpu/cpu.cfs_quota_us').strip.to_i
      period = File.read('/sys/fs/cgroup/cpu/cpu.cfs_period_us').strip.to_i

      # -1 means unlimited in cgroup v1
      return 0 if quota == -1 || period == 0

      # Calculate number of CPUs
      return (quota.to_f / period).ceil
    end

    # Unable to determine CPU limit, return 0
    # (will fallback to memory-based calculation)
    0
  end
end
