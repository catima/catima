module HasDeactivation
  extend ActiveSupport::Concern

  def not_deactivated?
    deactivated_at.nil?
  end

  def deactivated_at=(date)
    super(date == "now" ? Time.zone.now : date)
  end

  module ClassMethods
    def not_deactivated
      where(:deactivated_at => nil)
    end
  end
end
