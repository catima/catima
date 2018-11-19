# Module mixed into Item that encapsulates all the value management logic.
module Item::Values
  def unique_value_fields
    return if item_type.nil?

    fields.each do |f|
      errors.add(f.uuid.to_sym, "must be unique") if f.unique && number_of_items_with_value(f) > 0
    end
  end

  # Returns the value of the provided field for this item
  # field can be an instance of a field, a field UUID, or a field slug
  def get_value(field)
    field = item_type.find_field(field) unless field.is_a? Field
    field.value_for_item(self)
  end

  # Returns the value of the provided field for this item
  # if it is a simple item, or a ID (e.g. UUID or slug) for complex
  # fields. By default, it returns the same as get_value, but
  # subclasses can override this method
  def get_value_or_id(field)
    field = item_type.find_field(field) unless field.is_a? Field
    field.value_or_id_for_item(self)
    #TODO => field.field_value_for_item(self)
  end

  private

  def primary_text_value
    field = item_type.primary_text_field
    field&.raw_value(self) || ''
  end

  def number_of_items_with_value(field)
    conn = ActiveRecord::Base.connection.raw_connection
    sql = "SELECT COUNT(*) FROM items WHERE data->>'#{field.uuid}' = $1 AND item_type_id = $2"
    sql_data = [data[field.uuid], item_type_id]
    if id
      sql << " AND id <> $3"
      sql_data << id
    end
    res = conn.exec(sql, sql_data)
    res.getvalue(0, 0).to_i
  end

  def assign_default_values
    return if id || item_type.nil?

    data = {} if data.nil?
    fields.each do |f|
      data[f.uuid] = f.default_value if f.default_value.present?
    end
  end

  def assign_autoincrement_values
    return if item_type.nil?

    data = {} if data.nil?
    conn = ActiveRecord::Base.connection.raw_connection
    fields.each do |f|
      next unless (f.type == 'Field::Int') && !f.options.nil? && f.options['auto_increment'] && data[f.uuid].nil?

      st = conn.exec(
        "SELECT MAX(data->>'#{f.uuid}') FROM items WHERE item_type_id = $1",
        [item_type_id]
      )
      data[f.uuid] = st.getvalue(0, 0).to_i + 1
    end
  end
end
