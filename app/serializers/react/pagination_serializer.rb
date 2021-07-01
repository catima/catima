# Given an ActiveRecord scope of records, uses kaminari to paginate it and
# generates JSON with the current page of data, links to get the prev/next
# pages, and other pagination metadata.
#
# E.g.
#
# {
#     "_links": {
#         "first": "http://localhost:3000/api/v1/catalogs/library/items?page_number=1&page_size=25",
#         "last": "http://localhost:3000/api/v1/catalogs/library/items?page_number=40&page_size=25",
#         "next": "http://localhost:3000/api/v1/catalogs/library/items?page_number=2&page_size=25",
#         "prev": null
#     },
#     "items": [...],
#     "page_number": 1,
#     "page_size": 25,
#     "total_count": 1000,
#     "total_pages": 40
# }
#
class React::PaginationSerializer
  include Rails.application.routes.url_helpers

  DEFAULT_PAGE_SIZE = 25
  MAX_PAGE_SIZE = 100

  delegate :total_pages, :total_count,
           :first_page, :first_page?, :last_page, :last_page?,
           :next_page, :prev_page,
           :to => :paginated_records

  def initialize(key, scope, params)
    @key = key
    @scope = scope
    @params = params
    @page_number = [1, params[:page_number].to_i].max
    @page_size = valid_page_size(params[:page_size].to_i) || DEFAULT_PAGE_SIZE
  end

  def as_json(_options = nil)
    {
      key => serialized_paginated_records,
      :_links => links_json,
      :page_number => page_number,
      :page_size => page_size,
      :total_count => total_count,
      :total_pages => total_pages
    }
  end

  private

  attr_reader :key, :scope, :page_number, :page_size, :params

  def links_json
    {
      :first => page_url(1),
      :last => page_url(total_pages),
      :next => (page_url(next_page) unless last_page?),
      :prev => (page_url(prev_page) unless first_page?)
    }
  end

  def paginated_records
    @_paginated_records ||= scope.order(:id).page(page_number).per(page_size)
  end

  def serialized_paginated_records
    ActiveModel::Serializer::CollectionSerializer.new(
      paginated_records,
      :namespace => "React"
    )
  end

  def page_url(new_page)
    url_for(params.to_unsafe_h.merge(:page_number => new_page, :page_size => page_size))
  end

  def valid_page_size(value)
    value if value.in?(1..MAX_PAGE_SIZE)
  end
end
