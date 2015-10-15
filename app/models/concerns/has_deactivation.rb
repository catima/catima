module HasDeactivation
  extend ActiveSupport::Concern

  def active?
    deactivated_at.nil?
  end

  def deactivated_at=(date)
    super(date == "now" ? Time.zone.now : date)
  end

  module ClassMethods
    def active
      where(:deactivated_at => nil)
    end
  end
end
