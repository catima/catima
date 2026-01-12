# Patch for Rails 8.1 NullPool to support transaction isolation level
# Rails 8.1 NullPool compatibility patch
#
# Issue: In Rails 8.1, ActiveRecord::ConnectionAdapters::NullPool is missing
# the with_pool_transaction_isolation_level method, which causes transactions
# to fail in tests with: NoMethodError: undefined method 'with_pool_transaction_isolation_level'
#
# This patch adds the missing method to NullPool. Since NullPool doesn't actually
# manage real database connections, we simply execute the provided block.
#
# This patch can be removed when upgrading to a Rails version that fixes this issue.

module ActiveRecord
  module ConnectionAdapters
    class NullPool
      def with_pool_transaction_isolation_level(*_args)
        # NullPool doesn't manage real connections, so we just yield to the block
        yield if block_given?
      end
    end
  end
end
