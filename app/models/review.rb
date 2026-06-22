# Encapsulates the item review process, managing the review_status column for
# items and the transitions between those states. In the future, this class
# could also coordinate email notifications, etc.
#
class Review
  STATUSES = {
    "not-ready" => { :text => "draft", :color => "secondary" },
    "ready" => { :text => "review", :color => "info" },
    "rejected" => { :text => "rejected", :color => "warning" },
    "approved" => { :text => "approved", :color => "success" }
  }.freeze

  STATUS_OPTIONS = STATUSES.keys.freeze

  attr_reader :item

  delegate :review_status, :review_status=, :reviewer=, :to => :item

  def self.public_items_in_catalog(catalog)
    catalog.items.where(:review_status => "approved")
  end

  def self.status_options
    STATUS_OPTIONS
  end

  def initialize(item)
    @item = item
  end

  def submit_allowed?
    %w(not-ready rejected).include?(review_status)
  end

  def approved?
    review_status == "approved"
  end

  def rejected?
    review_status == "rejected"
  end

  # TODO: test
  def pending?
    review_status == "ready"
  end

  def approved(by:)
    self.review_status = "approved"
    self.reviewer = by
  end

  def rejected(by:)
    self.review_status = "rejected"
    self.reviewer = by
  end

  def submitted
    return unless submit_allowed?

    self.review_status = "ready"
  end
end
