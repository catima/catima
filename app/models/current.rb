class Current < ActiveSupport::CurrentAttributes
  # Store the current HTTP request object to make it available to serializers
  # and other components that need request context for URL generation
  attribute :request
end
# This class provides thread-safe storage for request context data that needs
# to be accessible throughout the request lifecycle, particularly for URL
# generation in serializers where the request context might not be directly available.
#
# ActiveSupport::CurrentAttributes automatically handles thread isolation and
# cleanup between requests, making it safe for use in multi-threaded environments.
