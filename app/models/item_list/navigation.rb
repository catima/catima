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
class ItemList::Navigation
  attr_reader :current, :offset

  def initialize(results:, current:, offset:)
    @results = results
    @current = current
    @offset = offset
  end

  # Provide a results wrapper that responds to total_count
  # for compatibility with views that expect paginated collections
  def results
    @results_wrapper ||= ResultsWrapper.new(@results)
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
    self.next && (offset_actual + 1)
  end

  def previous_offset
    previous && (offset_actual - 1)
  end

  def offset_actual
    return nil if current_index.nil?

    window_offset + current_index
  end

  private

  def window
    @window ||= results.offset(window_offset).limit(ItemList::PER).to_a
  end

  def window_offset
    [0, offset - 5].max
  end

  def current_index
    @current_index ||= if current.respond_to?(:id)
                         window.map(&:id).index(current.id)
                       else
                         window.index(current)
                       end
  end

  # Wrapper class to provide total_count for unpaginated relations
  class ResultsWrapper
    def initialize(relation)
      @relation = relation
    end

    def total_count
      @total_count ||= @relation.count
    end

    # Delegate all other methods to the underlying relation
    def method_missing(method, *args, &block)
      @relation.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      @relation.respond_to?(method, include_private) || super
    end
  end
end
