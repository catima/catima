class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    return unless enabled?

    super(data)
  end

  def track_event(data)
    return unless enabled?

    super(data)
  end

  private

  def enabled?
    ENV["AHOY_ENABLE_TRACKING"].present? ? to_boolean(ENV["AHOY_ENABLE_TRACKING"]) : true
  end

  def to_boolean(string)
    ActiveRecord::Type::Boolean.new.cast(string)
  end
end

# set to true for JavaScript tracking
Ahoy.api = false

# better user agent parsing
Ahoy.user_agent_parser = :device_detector

# better bot detection
Ahoy.bot_detection_version = 2
