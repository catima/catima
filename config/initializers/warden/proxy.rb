module Warden
  class Proxy
    def user(argument={})
      opts = argument.is_a?(Hash) ? argument : { :scope => argument }
      scope = (opts[:scope] ||= @config.default_scope)

      if @users.key?(scope)
        @users[scope]
      else
        unless user = request.original_fullpath.starts_with?("/api/v3") ? nil : session_serializer.fetch(scope)
          run_callbacks = opts.fetch(:run_callbacks, true)
          manager._run_callbacks(:after_failed_fetch, user, self, :scope => scope) if run_callbacks
        end

        @users[scope] = user ? set_user(user, opts.merge(:event => :fetch)) : nil
      end
    end
  end
end
