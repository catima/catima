# frozen_string_literal: true

require "test_helper"

class AdvisoryLockTest < ActiveSupport::TestCase
  def setup
    @lock_name = "test_lock"
    @lock_key = Zlib.crc32(@lock_name)
    @connection = ActiveRecord::Base.connection
  end

  test "executes block and returns true when lock is successfully acquired" do
    @connection.expects(:execute)
               .with("SELECT pg_try_advisory_lock(#{@lock_key})")
               .returns([{ "pg_try_advisory_lock" => true }])
    @connection.expects(:execute)
               .with("SELECT pg_advisory_unlock(#{@lock_key})")

    block_executed = false
    result = AdvisoryLock.with_lock(@lock_name) do
      block_executed = true
    end

    assert result
    assert block_executed
  end

  test "logs lock acquisition and release" do
    @connection.stubs(:execute)
               .with("SELECT pg_try_advisory_lock(#{@lock_key})")
               .returns([{ "pg_try_advisory_lock" => true }])
    @connection.stubs(:execute)
               .with("SELECT pg_advisory_unlock(#{@lock_key})")

    Rails.logger.expects(:info)
         .with("Advisory lock acquired: #{@lock_name} (key: #{@lock_key})")
    Rails.logger.expects(:info)
         .with("Advisory lock released: #{@lock_name} (key: #{@lock_key})")

    AdvisoryLock.with_lock(@lock_name) { true }
  end

  test "releases lock even if block raises an error" do
    @connection.stubs(:execute)
               .with("SELECT pg_try_advisory_lock(#{@lock_key})")
               .returns([{ "pg_try_advisory_lock" => true }])
    @connection.expects(:execute)
               .with("SELECT pg_advisory_unlock(#{@lock_key})")

    assert_raises(StandardError) do
      AdvisoryLock.with_lock(@lock_name) do
        raise StandardError, "Test error"
      end
    end
  end

  test "does not execute block and returns false when lock cannot be acquired" do
    @connection.expects(:execute)
               .with("SELECT pg_try_advisory_lock(#{@lock_key})")
               .returns([{ "pg_try_advisory_lock" => false }])

    block_executed = false
    result = AdvisoryLock.with_lock(@lock_name, timeout: 0) do
      block_executed = true
    end

    assert_not result
    assert_not block_executed
  end

  test "logs warning when lock cannot be acquired" do
    @connection.stubs(:execute)
               .with("SELECT pg_try_advisory_lock(#{@lock_key})")
               .returns([{ "pg_try_advisory_lock" => false }])

    Rails.logger
         .expects(:warn)
         .with("Could not acquire advisory lock: #{@lock_name} (key: #{@lock_key}). Task already running.")

    AdvisoryLock.with_lock(@lock_name) { true }
  end

  test "acquires blocking lock with timeout and executes block" do
    @connection.expects(:execute)
               .with("SELECT pg_advisory_lock(#{@lock_key})")
    @connection.expects(:execute)
               .with("SELECT pg_advisory_unlock(#{@lock_key})")

    block_executed = false
    result = AdvisoryLock.with_lock(@lock_name, timeout: 5) do
      block_executed = true
    end

    assert result
    assert block_executed
  end

  test "returns false when timeout is exceeded" do
    Timeout.stubs(:timeout).raises(Timeout::Error)

    Rails.logger
         .expects(:error)
         .with("Timeout waiting for advisory lock: #{@lock_name}")

    block_executed = false
    result = AdvisoryLock.with_lock(@lock_name, timeout: 5) do
      block_executed = true
    end

    assert_not result
    assert_not block_executed
  end

  test "generates consistent lock keys for same lock name" do
    first_key = nil
    second_key = nil

    @connection.stubs(:execute)
               .with do |sql|
                 if sql.include?("pg_try_advisory_lock")
                   match = sql.match(/pg_try_advisory_lock\((\d+)\)/)
                   first_key ||= match[1]
                   second_key = match[1] if first_key
                 end
                 true
               end
               .returns([{ "pg_try_advisory_lock" => true }])

    AdvisoryLock.with_lock("same_name") { true }
    AdvisoryLock.with_lock("same_name") { true }

    assert_equal first_key, second_key
  end

  test "generates different lock keys for different lock names" do
    keys = []

    @connection.stubs(:execute)
               .with do |sql|
                 if sql.include?("pg_try_advisory_lock")
                   match = sql.match(/pg_try_advisory_lock\((\d+)\)/)
                   keys << match[1]
                 end
                 true
               end
               .returns([{ "pg_try_advisory_lock" => true }])

    AdvisoryLock.with_lock("lock_one") { true }
    AdvisoryLock.with_lock("lock_two") { true }

    assert_not_equal keys[0], keys[1]
  end

  test "returns true when block is executed successfully" do
    @connection.stubs(:execute)
               .with("SELECT pg_try_advisory_lock(#{@lock_key})")
               .returns([{ "pg_try_advisory_lock" => true }])
    @connection.stubs(:execute)
               .with("SELECT pg_advisory_unlock(#{@lock_key})")

    result = AdvisoryLock.with_lock(@lock_name) { "block result" }

    assert result
  end

  test "returns false when lock cannot be acquired" do
    @connection.stubs(:execute)
               .with("SELECT pg_try_advisory_lock(#{@lock_key})")
               .returns([{ "pg_try_advisory_lock" => false }])

    result = AdvisoryLock.with_lock(@lock_name) { "block result" }

    assert_not result
  end
end
