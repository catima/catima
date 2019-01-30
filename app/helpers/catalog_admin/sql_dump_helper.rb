module CatalogAdmin::SqlDumpHelper
  def render_header_comment(header)
    "\n--\t ••• #{header} •••\n\n"
  end

  def render_comment(comment)
    "-- #{comment}\n"
  end

  def render_footer_comment
    "\n-- ••••••\n\n"
  end

  def remove_ending_comma!(statement)
    statement.gsub!(/,$/, '')
  end
end
