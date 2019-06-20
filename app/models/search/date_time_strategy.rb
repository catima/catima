# Beware, timestamps returned by the Datepicker React component are given in milliseconds!
class Search::DateTimeStrategy < Search::BaseStrategy
  permit_criteria :exact, :condition, :field_condition, :start => {}, :end => {}

  def keywords_for_index(item)
    date_for_keywords(item)
  end

  def search(scope, criteria)
    field_condition = criteria[:condition]
    negate = criteria[:field_condition] == "exclude"

    return scope if criteria[:start].blank?

    start_condition = criteria[:start].keys.first
    start_date_time = criteria[:start][start_condition]

    if criteria.key?(:end)
      end_condition = criteria[:end].keys.first
      end_date_time = criteria[:end][end_condition] if end_date?(criteria)
    end

    return scope if components_empty?(start_date_time) && components_empty?(end_date_time)

    scope = append_where_date_is_set(scope) unless negate
    scope = search_with_start_date(scope, criteria, start_date_time, field_condition, negate)
    scope = search_interval_dates(
      scope, criteria, { :start => start_date_time, :end => end_date_time }, negate, field_condition
    )

    scope
  end

  private

  def date_for_keywords(item)
    return date_from_hash(raw_value(item)) if raw_value(item).is_a?(Hash)

    raw_value(item)
  end

  def date_from_hash(hash)
    hash.each_with_object([]) { |(_, v), array| array << v if v.present? }
  end

  def start_date?(criteria)
    condition = criteria[:start].keys.first
    criteria[:start].present? && criteria[:start][condition].present?
  end

  def end_date?(criteria)
    criteria[:end].present? && criteria[:end][criteria[:end].keys.first].present?
  end

  def search_with_start_date(scope, criteria, start_date_time, field_condition, negate)
    return scope unless start_date?(criteria)

    return exact_search(scope, start_date_time, negate) if field_condition["exact"].present?
    return inexact_search(scope, start_date_time, field_condition, negate) if %w[before after].include?(field_condition)

    scope
  end

  def search_interval_dates(scope, criteria, dates, negate, field_condition)
    return scope unless end_date?(criteria)

    return scope unless %w[outside between].include?(field_condition)

    interval_search(scope, dates[:start], dates[:end], field_condition, negate)
  end

  def exact_search(scope, date_time, negate)
    date_components = date_time.select { |_, value| value.present? }
    sql = date_components.map { |k, _| "#{data_field_expr(k)} LIKE ?" }.join(" AND ")

    s = ->(*q) { negate ? scope.where.not(q).or(scope.where("#{sql_select_table_name}.data->'#{field.uuid}' IS NULL")) : scope.where(q) }

    s.call(sql, *date_components.map { |_key, value| "%#{value}%" })
  end

  def inexact_search(scope, date_time, field_condition, negate)
    case field_condition
    when "before"
      sql_operator = negate ? ">" : "<"
    when "after"
      sql_operator = negate ? "<" : ">"
    end

    scope.where(
      "#{convert_to_timestamp(concat_json_date(date_time))} #{sql_operator}
      to_timestamp(?, '#{field_date_format_to_sql_format}')", date_remove_utc(date_time)
    )
  end

  def interval_search(scope, start_date_time, end_date_time, field_condition, negate)
    return inexact_search(scope, end_date_time, "before", field_condition == "outside") if start_date_time.blank?
    return inexact_search(scope, start_date_time, "after", field_condition == "outside") if end_date_time.blank?

    field_condition = field_condition == "between" ? "outside" : "between" if negate

    where_scope = ->(*q) { field_condition == "outside" ? scope.where.not(q) : scope.where(q) }

    where_scope.call(
      "#{convert_to_timestamp(concat_json_date(start_date_time))}
      BETWEEN to_timestamp(?, '#{field_date_format_to_sql_format}')
      AND to_timestamp(?, '#{field_date_format_to_sql_format}')",
      date_remove_utc(start_date_time),
      date_remove_utc(end_date_time)
    )
  end

  # rubocop:disable Metrics/MethodLength
  def concat_json_date(date_time)
    "CONCAT(
      CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->>'Y' IS NULL
           THEN '#{date_time_component(date_time, 'Y')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'Y', 4, '0')
           END,
        '-',
      CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->>'M' IS NULL
           THEN '#{date_time_component(date_time, 'M')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'M', 2, '0')
           END,
        '-',
      CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->>'D' IS NULL
           THEN '#{date_time_component(date_time, 'D')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'D', 2, '0')
           END,
        ' ',
      CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->>'h' IS NULL
           THEN '#{date_time_component(date_time, 'h')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'h', 2, '0')
           END,
        ':',
      CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->>'m' IS NULL
           THEN '#{date_time_component(date_time, 'm')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'m', 2, '0')
           END,
        ':',
      CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->>'s' IS NULL
           THEN '#{date_time_component(date_time, 's')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'s', 2, '0')
           END
    )"
  end
  # rubocop:enable Metrics/MethodLength

  def convert_to_timestamp(datetime)
    "to_timestamp(#{datetime}, '#{field_date_format_to_sql_format}')"
  end

  def field_date_format_to_sql_format
    "YYYY-MM-DD hh24:mi:ss"
  end

  def date_remove_utc(date)
    utc_date = "#{date_time_component(date, 'Y')}-#{date_time_component(date, 'M')}-#{date_time_component(date, 'D')}"
    utc_date << " #{date_time_component(date, 'h')}:#{date_time_component(date, 'm')}:#{date_time_component(date, 's')}"

    # date.strftime("%Y-%m-%d %H:%M:%S")
  end

  def append_where_date_is_set(scope)
    scope.where("#{sql_select_table_name}.data->'#{field.uuid}' IS NOT NULL")
  end

  def data_field_expr(date_component)
    case date_component
    when "Y"
      "LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'#{date_component}', 4, '0')"
    else
      "LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->>'#{date_component}', 2, '0')"
    end
  end

  def date_time_component(date_time, key)
    return date_time[key].presence || "0000" if key == "Y"

    date_time[key].presence || "00"
  end

  def components_empty?(date_time)
    date_time.each { |_key, value| return false if value.present? }

    true
  end
end
