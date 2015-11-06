module Search::Strategies
  private

  def strategies
    fields.map do |field|
      klass = "Search::#{field.class.name.sub(/^Field::/, '')}Strategy"
      klass.constantize.new(field, locale)
    end
  end
end
