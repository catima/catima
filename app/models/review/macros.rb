# Mix-in for Item that adds ActiveRecord validations and callbacks needed for
# Review logic. This is the glue between the Item and Review classes.
#
module Review::Macros
  extend ActiveSupport::Concern

  included do
    attr_accessor :submit_for_review

    belongs_to(
      :reviewer,
      -> { unscope(where: :deleted_at) },
      :class_name => "User",
      inverse_of: :reviews,
      optional: true
    )
    validates_inclusion_of :review_status,
                           :in => %w(not-ready ready rejected approved)
    before_save :handle_submit_for_review
  end

  def review
    @review ||= catalog.requires_review? ? Review.new(self) : Review::Noop.new(self)
  end

  private

  def handle_submit_for_review
    review.submitted if submit_for_review == "1"
    true
  end
end
