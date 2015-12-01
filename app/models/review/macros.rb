# Mix-in for Item that adds ActiveRecord validations and callbacks needed for
# Review logic. This is the glue between the Item and Review classes.
#
module Review::Macros
  extend ActiveSupport::Concern

  included do
    attr_accessor :submit_for_review
    belongs_to :reviewer, :class_name => "User"
    validates_inclusion_of :review_status,
                           :in => %w(not-ready ready rejected approved)
    before_save :handle_submit_for_review
  end

  def review
    @review ||= begin
      catalog.requires_review? ? Review.new(self) : Review::Noop.new(self)
    end
  end

  private

  def handle_submit_for_review
    review.submitted if submit_for_review == "1"
    true
  end
end
