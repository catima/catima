# Beware, timestamps returned by the Datepicker React component are given in milliseconds!
class Search::ComplexDatationStrategy < Search::BaseStrategy
  permit_criteria :exact, :condition, :field_condition, :exclude_condition, :default, :child_choices_activated, :start => {}, :end => {}
  include Search::MultivaluedSearch

  def keywords_for_index(item)
    if field.selected_format(item) == 'datation_choice'
      choices = field.selected_choices(item)
      choices.flat_map { |choice| [choice.short_name, choice.long_name] }
    else
      date_for_keywords(item)
    end
  end

  def search(scope, criteria)
    field_condition = criteria[:condition]
    exclude_condition = criteria[:exclude_condition]
    negate = criteria[:field_condition] == "exclude"

    scope = append_joins_on_choices_and_choice_sets(scope)
    scope = exclude_from_scope(scope, exclude_condition)
    if criteria[:default]
      choice = Choice.find(criteria[:default])
      start_date_time = JSON.parse(choice.from_date)
      end_date_time = JSON.parse(choice.to_date)

      if criteria[:child_choices_activated] == "true"
        original_scope = scope
        id_scope = search_data_matching_more_complex_datation_choice(
          original_scope,
          (choice.childrens.pluck(:id) + [(criteria[:default] || criteria[:exact]).to_i])
            .flatten.map { |id| id.to_s },
          negate
        )

        if negate
          date_scope = scope.where("#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time'")
          date_scope = append_where_data_is_set(date_scope)
          scope = id_scope.or(date_scope)
        else
          scope = id_scope.or(search_dates(original_scope, start_date_time, end_date_time, field_condition, negate, true))

          choice.childrens.each do |c|
            start_date_time = JSON.parse(c.from_date)
            end_date_time = JSON.parse(c.to_date)
            scope = scope.or(search_dates(original_scope, start_date_time, end_date_time, field_condition, negate, true))
          end
        end
        scope
      else
        id_scope = search_data_matching_more_complex_datation_choice(scope, criteria[:default], negate)

        if negate
          date_scope = scope.where("#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time'")
          date_scope = append_where_data_is_set(date_scope)
        else
          date_scope = search_dates(scope, start_date_time, end_date_time, field_condition, negate, true)
        end
        scope = id_scope.or(date_scope)
      end
      return scope
    end

    return scope if criteria[:start].blank? && criteria[:end].blank?

    start_condition = criteria[:start].keys.first
    start_date_time = criteria[:start][start_condition]

    end_condition = criteria[:end].keys.first
    end_date_time = criteria[:end][end_condition] if end_date?(criteria)

    search_dates(scope, start_date_time, end_date_time, field_condition, negate, false)
  end

  def browse(scope, choice_slug)
    choice = choice_from_slug(choice_slug)
    return scope.none if choice.nil?

    search(scope, { default: choice.id.to_s, exclude_condition: 'datation' })
  end

  private

  def choice_from_slug(slug)
    _id, name = slug.split("-", 2)

    return if name.blank?

    choice_sets = ChoiceSet.where(id: field.choice_set_ids)
    Choice.where(choice_set_id: choice_sets.pluck(:id)).find(_id)
  end

  def search_dates(scope, start_date_time, end_date_time, field_condition, negate, is_choice)
    return scope if components_empty?(start_date_time) && components_empty?(end_date_time)

    if is_choice
      field_condition = if components_empty?(start_date_time)
                          "before"
                        elsif components_empty?(end_date_time)
                          "after"
                        elsif end_date_time == start_date_time
                          "exact"
                        else
                          "between"
                        end
    end

    scope = append_where_data_is_set(scope) unless negate
    scope = append_joins_on_choices_and_choice_sets(scope)

    interval_search(scope, start_date_time, end_date_time, field_condition, negate, is_choice)
  end

  def exclude_from_scope(scope, exclude_condition)
    if exclude_condition == "datation"
      scope.where("#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'datation_choice'")
    elsif exclude_condition == "datation_choice"
      scope.where("#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time'")
    else
      scope
    end
  end

  def date_for_keywords(item)
    return date_from_hash(raw_value(item)) if raw_value(item).is_a?(Hash)

    raw_value(item)
  end

  def date_from_hash(hash, search_data = [])
    search_data << hash["from"].each_with_object([]) { |(_, v), array| array << v if v.present? } if hash.key?("from")
    search_data << hash["to"].each_with_object([]) { |(_, v), array| array << v if v.present? } if hash.key?("to")
  end

  def start_date?(criteria)
    condition = criteria[:start].keys.first
    criteria[:start].present? && criteria[:start][condition].present?
  end

  def end_date?(criteria)
    criteria[:end].present? && criteria[:end][criteria[:end].keys.first].present?
  end

  def inexact_search(scope, date_time, field_condition, negate, is_choice)
    if field_condition == "before" && negate
      field_condition = "after"
      negate = false
    elsif field_condition == "after" && negate
      field_condition = "before"
      negate = false
    end

    case field_condition
    when "exact"
      sql_operator = negate ? "!=" : "="
      init_scope = scope.where(
        "#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time' AND
           #{date_time_to_interval(date_time, 'from')} #{sql_operator} #{make_interval(date_time)} AND
           #{date_time_to_interval(date_time, 'to')}  #{sql_operator} #{make_interval(date_time)}")
      scope = is_choice ? init_scope : init_scope.or(
        scope.where(
          "#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'datation_choice' AND
             #{choice_to_interval(date_time, 'from_date')} #{sql_operator} #{make_interval(date_time)} AND
             #{choice_to_interval(date_time, 'to_date')}  #{sql_operator} #{make_interval(date_time)}")
      )
    when "before"
      sql_operator = negate ? ">=" : "<="
      init_scope = scope.where(
        "#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time' AND
           (
           ( ((NOT (#{where_date_is_not_set('to')})) AND (NOT (#{where_date_is_not_set('from')}))) AND  ((#{date_time_to_interval(date_time,
                                                                                                                                  'from')} #{sql_operator} #{make_interval(date_time)}) OR (#{date_time_to_interval(
          date_time, 'to')} #{sql_operator} #{make_interval(date_time)})) ) OR
           ((#{where_date_is_not_set('to')}) AND (#{date_time_to_interval(date_time, 'from')} #{sql_operator} #{make_interval(date_time)})) OR
           (#{where_date_is_not_set('from')}))"
      )
      scope = is_choice ? init_scope : init_scope.or(
        scope.where(
          "#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'datation_choice' AND
           (
           ( ((NOT (#{where_choice_date_is_not_set('to_date')})) AND (NOT (#{where_choice_date_is_not_set('from_date')}))) AND  ((#{choice_to_interval(date_time,
                                                                                                                                                       'from_date')} #{sql_operator} #{make_interval(date_time)}) OR (#{choice_to_interval(
            date_time, 'to_date')} #{sql_operator} #{make_interval(date_time)})) ) OR
           ((#{where_choice_date_is_not_set('to_date')}) AND (#{choice_to_interval(date_time, 'from_date')} #{sql_operator} #{make_interval(date_time)})) OR
           (#{where_choice_date_is_not_set('from_date')}))")
      )
    when "after"
      sql_operator = negate ? "<=" : ">="
      init_scope = scope.where(
        "#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time' AND
           ( ((NOT (#{where_date_is_not_set('to')})) AND (NOT (#{where_date_is_not_set('from')}))) AND ((#{date_time_to_interval(date_time,
                                                                                                                                 'from')} #{sql_operator} #{make_interval(date_time)}) OR (#{date_time_to_interval(
          date_time, 'to')} #{sql_operator} #{make_interval(date_time)})) OR
           ((#{where_date_is_not_set('from')}) AND (#{date_time_to_interval(date_time, 'to')} #{sql_operator} #{make_interval(date_time)})) OR
           (#{where_date_is_not_set('to')}))"
      )
      scope = is_choice ? init_scope : init_scope.or(
        scope.where(
          "#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'datation_choice' AND
           (
           ( ((NOT (#{where_choice_date_is_not_set('from_date')})) AND (NOT (#{where_choice_date_is_not_set('to_date')}))) AND  ((#{choice_to_interval(date_time,
                                                                                                                                                       'from_date')} #{sql_operator} #{make_interval(date_time)}) OR (#{choice_to_interval(
            date_time, 'to_date')} #{sql_operator} #{make_interval(date_time)})) ) OR
           ((#{where_choice_date_is_not_set('from_date')}) AND (#{choice_to_interval(date_time, 'to_date')} #{sql_operator} #{make_interval(date_time)})) OR
           (#{where_choice_date_is_not_set('to_date')}))")
      )
    end
    scope
  end

  def interval_search(scope, start_date_time, end_date_time, field_condition, negate, is_choice)
    return inexact_search(scope, start_date_time, field_condition, negate, is_choice) if field_condition != 'outside' && field_condition != 'between'

    field_condition = field_condition == "between" ? "outside" : "between" unless negate

    where_scope = ->(*q, name) {
      field_condition == "outside" ? scope.where("#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = '#{name}'").where('items.id NOT IN (?)',
                                                                                                                                         scope.where(q).any? ? scope.where(q).pluck(:id) : ['0']) : scope.where(q)
    }

    date_time_query_string = "
            (#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time' AND
            ((NOT #{where_date_is_not_set('from')}) OR (NOT #{where_date_is_not_set('to')}) ) AND
            (
              (
                 ((#{where_date_is_not_set('to')})) AND (#{date_time_to_interval(start_date_time,
                                                                                 'from')} > #{make_interval(start_date_time)} AND #{date_time_to_interval(start_date_time,
                                                                                                                                                          'from')} > #{make_interval(end_date_time)})
              ) OR (
                 ((#{where_date_is_not_set('from')})) AND (#{date_time_to_interval(start_date_time,
                                                                                   'to')} < #{make_interval(start_date_time)} AND #{date_time_to_interval(start_date_time,
                                                                                                                                                          'to')} < #{make_interval(end_date_time)})
              ) OR (
                ((NOT #{where_date_is_not_set('from')}) AND (NOT #{where_date_is_not_set('to')}) ) AND
                  (
                      (
                        (#{date_time_to_interval(start_date_time,
                                                 'from')} > #{make_interval(start_date_time)} AND #{date_time_to_interval(start_date_time, 'from')} > #{make_interval(end_date_time)})
                        AND
                        (#{date_time_to_interval(start_date_time,
                                                 'to')} > #{make_interval(start_date_time)} AND #{date_time_to_interval(start_date_time, 'to')} > #{make_interval(end_date_time)})
                      ) OR (
                        (#{date_time_to_interval(start_date_time,
                                                 'from')} < #{make_interval(start_date_time)} AND #{date_time_to_interval(start_date_time, 'from')} < #{make_interval(end_date_time)})
                        AND
                        (#{date_time_to_interval(start_date_time,
                                                 'to')} < #{make_interval(start_date_time)} AND #{date_time_to_interval(start_date_time, 'to')} < #{make_interval(end_date_time)})
                      )
                  )
              )
            ))"

    datation_query_string = "
           (#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'datation_choice' AND
           (
              (
                ((#{where_choice_date_is_not_set('to_date')})) AND (#{choice_to_interval(start_date_time,
                                                                                         'from_date')} > #{make_interval(start_date_time)} AND #{choice_to_interval(start_date_time,
                                                                                                                                                                    'from_date')} > #{make_interval(end_date_time)})
              ) OR (
                ((#{where_choice_date_is_not_set('from_date')})) AND (#{choice_to_interval(start_date_time,
                                                                                           'from_date')} < #{make_interval(start_date_time)} AND #{choice_to_interval(start_date_time,
                                                                                                                                                                      'from_date')} < #{make_interval(end_date_time)})
              ) OR (
                ((NOT #{where_choice_date_is_not_set('from_date')}) AND (NOT #{where_choice_date_is_not_set('to_date')}) ) AND
                  (
                        (
                          (#{choice_to_interval(start_date_time,
                                                'from_date')} < #{make_interval(start_date_time)} AND #{choice_to_interval(start_date_time, 'from_date')} < #{make_interval(end_date_time)})
                          AND
                          (#{choice_to_interval(start_date_time,
                                                'to_date')} < #{make_interval(start_date_time)} AND #{choice_to_interval(start_date_time, 'to_date')} < #{make_interval(end_date_time)})
                        ) OR (
                          (#{choice_to_interval(start_date_time,
                                                'from_date')} > #{make_interval(start_date_time)} AND #{choice_to_interval(start_date_time, 'from_date')} > #{make_interval(end_date_time)})
                          AND
                          (#{choice_to_interval(start_date_time,
                                                'to_date')} > #{make_interval(start_date_time)} AND #{choice_to_interval(start_date_time, 'to_date')} > #{make_interval(end_date_time)})
                        )
                  )
              )
           ))"

    date_time_scope = where_scope.call(date_time_query_string, 'date_time')
    datation_choice_scope = where_scope.call(datation_query_string, 'datation_choice')
    is_choice ? date_time_scope : date_time_scope.or(datation_choice_scope)
  end

  def date_time_to_interval(date_time, date_name)
    "
    ((CASE WHEN '#{field.allow_date_time_bc?}' = 'true' AND #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'BC' = 'true'
    THEN -1
    ELSE 1
    END)  *
    make_interval(
        years := (CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'Y' IS NULL
           THEN '#{date_time_component(date_time, 'Y')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'Y', 4, '0')
           END)::int,
        months := (CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'M' IS NULL
           THEN '#{date_time_component(date_time, 'M')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'M', 2, '0')
           END)::int ,
        days := (CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'D' IS NULL
           THEN '#{date_time_component(date_time, 'D')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'D', 2, '0')
           END)::int ,
        hours := (CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'h' IS NULL
           THEN '#{date_time_component(date_time, 'h')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'h', 2, '0')
           END)::int ,
        mins := (CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'m' IS NULL
           THEN '#{date_time_component(date_time, 'm')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'m', 2, '0')
           END)::int ,
        secs := (CASE WHEN #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'s' IS NULL
           THEN '#{date_time_component(date_time, 's')}'
           ELSE LPAD(#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'s', 2, '0')
           END)::int
    ))"
  end

  def choice_to_interval(date_time, date_name)
    "
    ((CASE WHEN choice_sets.allow_bc = 'true' AND choices.#{date_name}::jsonb->>'BC' = 'true'
    THEN -1
    ELSE 1
    END)  *
    make_interval(
        years := (CASE WHEN choices.#{date_name}::jsonb->>'Y' IS NULL
           THEN '#{date_time_component(date_time, 'Y')}'
           ELSE LPAD(choices.#{date_name}::jsonb->>'Y', 4, '0')
           END)::int ,
        months := (CASE WHEN choices.#{date_name}::jsonb->>'M' IS NULL
           THEN '#{date_time_component(date_time, 'M')}'
           ELSE LPAD(choices.#{date_name}::jsonb->>'M', 2, '0')
           END)::int ,
        days := (CASE WHEN choices.#{date_name}::jsonb->>'D' IS NULL
           THEN '#{date_time_component(date_time, 'D')}'
           ELSE LPAD(choices.#{date_name}::jsonb->>'D', 2, '0')
           END)::int ,
        hours := (CASE WHEN choices.#{date_name}::jsonb->>'h' IS NULL
           THEN '#{date_time_component(date_time, 'h')}'
           ELSE LPAD(choices.#{date_name}::jsonb->>'h', 2, '0')
           END)::int ,
        mins := (CASE WHEN choices.#{date_name}::jsonb->>'m' IS NULL
           THEN '#{date_time_component(date_time, 'm')}'
           ELSE LPAD(choices.#{date_name}::jsonb->>'m', 2, '0')
           END)::int ,
        secs := (CASE WHEN choices.#{date_name}::jsonb->>'s' IS NULL
           THEN '#{date_time_component(date_time, 's')}'
           ELSE LPAD(choices.#{date_name}::jsonb->>'s', 2, '0')
           END)::int
      )
    )"
  end

  def make_interval(date_time)
    "(#{date_time['BC'] ? -1 : 1} * make_interval(
        years := ('#{date_time_component(date_time, 'Y')}')::int,
        months := ('#{date_time_component(date_time, 'M')}')::int ,
        days := ('#{date_time_component(date_time, 'D')}')::int ,
        hours := ('#{date_time_component(date_time, 'h')}')::int ,
        mins := ('#{date_time_component(date_time, 'm')}')::int ,
        secs := ('#{date_time_component(date_time, 's')}')::int
    ))"
  end

  def where_date_is_not_set(date_name)
    "((#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'Y' IS NULL OR #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'Y' = '') AND
      (#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'M' IS NULL OR #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'M' = '') AND
      (#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'D' IS NULL OR #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'D' = '') AND
      (#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'h' IS NULL OR #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'h' = '') AND
      (#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'m' IS NULL OR #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'m' = '') AND
      (#{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'s' IS NULL OR #{sql_select_table_name}.data->'#{field.uuid}'->'#{date_name}'->>'s' = ''))"
  end

  def where_choice_date_is_not_set(date_name)
    "((choices.#{date_name}::jsonb->>'Y' IS NULL OR choices.#{date_name}::jsonb->>'Y' = '') AND
      (choices.#{date_name}::jsonb->>'M' IS NULL OR choices.#{date_name}::jsonb->>'M' = '') AND
      (choices.#{date_name}::jsonb->>'D' IS NULL OR choices.#{date_name}::jsonb->>'D' = '') AND
      (choices.#{date_name}::jsonb->>'h' IS NULL OR choices.#{date_name}::jsonb->>'h' = '') AND
      (choices.#{date_name}::jsonb->>'m' IS NULL OR choices.#{date_name}::jsonb->>'m' = '') AND
      (choices.#{date_name}::jsonb->>'s' IS NULL OR choices.#{date_name}::jsonb->>'s' = ''))"
  end

  def append_where_data_is_set(scope)
    scope.where("(#{sql_select_table_name}.data->'#{field.uuid}' IS NOT NULL)
      AND (
        (#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'date_time' AND ((NOT (#{where_date_is_not_set('from')})) OR (NOT (#{where_date_is_not_set('to')}))) )
        OR (#{sql_select_table_name}.data->'#{field.uuid}'->>'selected_format' = 'datation_choice' AND  coalesce(items.data->'#{field.uuid}'->'selected_choices'->'value', NULL) IS NOT NULL)
      )
    ")
  end

  def append_joins_on_choices_and_choice_sets(scope)
    query = Item.select("*, jsonb_array_elements_text(coalesce(items.data->'#{field.uuid}'->'selected_choices'->'value','[0]')) AS choice_id")
    scope.from("(#{query.to_sql}) items").joins("left join choices ON (choices.id = choice_id::INT) left join choice_sets ON choice_sets.id = choices.choice_set_id")
  end

  def date_time_component(date_time, key)
    return date_time[key].presence || "0000" if key == "Y"

    date_time[key].presence || "00"
  end

  def components_empty?(date_time)
    date_time.each { |_key, value| return false if value.present? }

    true
  end

  def data_field_expr
    "choice_id::text"
  end
end
