module HasSqlSlug
  extend ActiveSupport::Concern

  MYSQL_NAME_MAX_LENGTH = 64

  def sql_slug
    slug.present? ? slug.truncate(MYSQL_NAME_MAX_LENGTH) : 'undefined-slug'
  end
end
