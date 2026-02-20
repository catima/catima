# frozen_string_literal: true

require 'zlib'

module AdvisoryLock
  # Execute a block with an advisory lock to prevent concurrent execution
  # across multiple application instances
  #
  # @param lock_name [String] A unique name for the lock
  # @param timeout [Integer] Maximum time to wait for the lock in seconds (0 = no wait)
  # @yield The block to execute while holding the lock
  # @return [Boolean] true if the lock was acquired and block executed, false otherwise
  def self.with_lock(lock_name, timeout: 0)
    # Generate a consistent lock key from the lock name
    # PostgreSQL advisory locks use bigint, so we need a number
    lock_key = Zlib.crc32(lock_name)
    quoted_key = ActiveRecord::Base.connection.quote(lock_key)

    acquired = false

    begin
      # Try to acquire the lock
      if timeout.zero?
        # Non-blocking: try to get lock immediately
        acquired = ActiveRecord::Base.connection.execute(
          "SELECT pg_try_advisory_lock(#{quoted_key})"
        ).first['pg_try_advisory_lock']
      else
        # Blocking with timeout
        Timeout.timeout(timeout) do
          ActiveRecord::Base.connection.execute(
            "SELECT pg_advisory_lock(#{quoted_key})"
          )
          acquired = true
        end
      end

      if acquired
        Rails.logger.info("Advisory lock acquired: #{lock_name} (key: #{lock_key})")
        yield
        true
      else
        Rails.logger.warn("Could not acquire advisory lock: #{lock_name} (key: #{lock_key}). Task already running.")
        false
      end
    rescue Timeout::Error
      Rails.logger.error("Timeout waiting for advisory lock: #{lock_name}")
      false
    ensure
      if acquired
        # Release the lock
        ActiveRecord::Base.connection.execute(
          "SELECT pg_advisory_unlock(#{quoted_key})"
        )
        Rails.logger.info("Advisory lock released: #{lock_name} (key: #{lock_key})")
      end
    end
  end
end
