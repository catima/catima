# Given a search result (i.e. an ActiveRecord query object that responds to
# `offset`, `limit`, and `to_a`) and the current position in that result,
# determine the next and previous items.
#
# Since search results can shift or change during navigation, the current item
# may no longer be at the offset it was when the navigation started. This class
# tries to handle such cases gracefully. If the results have changed so much
# that the item no longer seems to be in it, the next and previous will be nil.
#
# If the offset of the current item is still in the result but has shifted,
# its new offset can be obtained by calling `offset_actual`.
#
class Search::Navigation
  attr_reader :results, :current, :offset

  def initialize(results:, current:, offset:)
    @results = results
    @current = current
    @offset = offset
  end

  def next
    current_index && window[current_index + 1]
  end

  def previous
    case current_index
    when nil then nil
    when 0 then nil
    else window[current_index - 1]
    end
  end

  def next_offset
    self.next && offset_actual + 1
  end

  def previous_offset
    previous && offset_actual - 1
  end

  def offset_actual
    return nil if current_index.nil?
    window_offset + current_index
  end

  private

  def window
    @window ||= results.offset(window_offset).limit(11).to_a
  end

  def window_offset
    [0, offset - 5].max
  end

  def current_index
    @current_index ||= window.index(current)
  end
end
