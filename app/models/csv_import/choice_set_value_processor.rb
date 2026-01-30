# Processes CSV values for choice set fields during import. This class handles:
#
# * Parsing pipe-separated (|) choice names from CSV values
# * Finding existing choices by short_name in the specified language
# * Creating new top-level choices when they don't exist
# * Returning choice IDs (single or array) for assignment to items
#
# Both i18n and non-i18n choice sets are supported. For i18n fields, the locale
# is determined by the CSV column (e.g., "language (fr)" for French). For non-i18n
# fields, the catalog's primary language is used. When searching, ALL choices are
# matched (including children), but new choices are always created as top-level (no parent_id).
#
class CSVImport::ChoiceSetValueProcessor
  SEPARATOR = '|'.freeze

  attr_reader :field, :choice_set, :catalog, :locale, :warnings

  def initialize(field, locale)
    @field = field
    @choice_set = field.choice_set
    @catalog = field.catalog
    @locale = locale
    @warnings = []
  end

  # Processes a CSV value (string) and returns the appropriate value for
  # assignment to an item. For single choice fields, returns a single choice ID.
  # For multiple choice fields, returns an array of choice IDs.
  #
  # Creates new choices as needed when they don't exist in the choice set.
  #
  def process(csv_value)
    return nil if csv_value.blank?

    choice_names = parse_choice_names(csv_value)
    choice_ids = choice_names.map { |name| find_or_create_choice(name).id }

    field.multiple? ? choice_ids : choice_ids.first
  end

  # Processes i18n choice set fields where we have multiple locale values
  # (e.g., {"en" => "English", "fr" => "Anglais"}).
  # Returns choice ID(s) for assignment to items, creating or updating choices
  # to include all provided translations.
  #
  def process_i18n(locale_values)
    return nil if locale_values.empty?

    # Normalize locale keys to symbols for consistency
    locale_values = normalize_locale_keys(locale_values)

    # For each locale, parse the choice names
    # We need to align them across locales (assume same order/count)
    parsed_by_locale = {}
    locale_values.each do |loc, value|
      parsed_by_locale[loc] = value.split(SEPARATOR).map(&:strip).compact_blank
    end

    # Get the maximum number of choices across all locales
    max_choices = parsed_by_locale.values.map(&:size).max
    return nil if max_choices.zero?

    # Process each choice position
    choice_ids = []
    max_choices.times do |index|
      # Collect the name for this choice in each locale
      names_by_locale = {}
      parsed_by_locale.each do |loc, names|
        names_by_locale[loc] = names[index] if names[index].present?
      end

      next if names_by_locale.empty?

      choice = find_or_create_choice_i18n(names_by_locale)
      choice_ids << choice.id
    end

    field.multiple? ? choice_ids : choice_ids.first
  end

  private

  def parse_choice_names(csv_value)
    names = csv_value.split(SEPARATOR).map(&:strip).compact_blank

    # For single choice fields, only take the first value
    field.multiple? ? names : names.take(1)
  end

  def find_or_create_choice(short_name)
    # Find ALL choices with this short_name to detect duplicates
    matching_choices = choice_set.choices.short_named(short_name, locale).to_a

    if matching_choices.size > 1
      # Multiple choices with the same name - create a warning
      add_ambiguous_choice_warning(short_name, matching_choices)
    end

    # Use the first match if found
    return matching_choices.first if matching_choices.any?

    # Create new top-level choice
    create_choice(short_name)
  end

  # Find or create a choice with multiple locale translations
  def find_or_create_choice_i18n(names_by_locale)
    # Try to find an existing choice that has ALL the provided names in their respective locales
    # This ensures we don't create duplicates when the same choice is described in multiple languages

    # First, collect all potential matching choices for each locale
    candidates_by_locale = {}
    names_by_locale.each do |loc, name|
      candidates_by_locale[loc] = choice_set.choices.short_named(name, loc).to_a
    end

    # Find choices that appear in ALL locales (intersection)
    all_candidates = candidates_by_locale.values.flatten.uniq
    matching_choice = all_candidates.find do |candidate|
      # Check if this candidate matches all provided names
      names_by_locale.all? do |loc, name|
        candidate.public_send("short_name_#{loc}") == name
      end
    end

    if matching_choice
      # Found an exact match with all translations
      # Check for ambiguous matches in any locale
      names_by_locale.each do |loc, name|
        choices = candidates_by_locale[loc]
        add_ambiguous_choice_warning(name, choices) if choices.size > 1
      end
      return matching_choice
    end

    # No exact match found, but maybe a partial match exists
    # Try to find a choice that matches at least one locale
    partial_match = nil
    names_by_locale.each do |loc, name|
      choices = candidates_by_locale[loc]
      next unless choices.any?

      partial_match = choices.first
      # Check for ambiguous matches
      add_ambiguous_choice_warning(name, choices) if choices.size > 1
      break
    end

    if partial_match
      # Update existing choice with missing translations
      update_choice_translations(partial_match, names_by_locale)
      return partial_match
    end

    # Create new choice with all translations
    create_choice_i18n(names_by_locale)
  end

  def update_choice_translations(choice, names_by_locale)
    needs_update = false
    names_by_locale.each do |loc, name|
      attr_name = "short_name_#{loc}"
      next if choice.public_send(attr_name).present?

      # Ensure the name is UTF-8 encoded
      name = name.to_s.force_encoding('UTF-8')
      choice.public_send("#{attr_name}=", name)
      needs_update = true
    end

    choice.save! if needs_update
  end

  def add_ambiguous_choice_warning(short_name, matching_choices)
    choice_details = matching_choices.map { |choice| "id: #{choice.id}" }

    @warnings << {
      type: :ambiguous_choice,
      choice_name: short_name,
      count: matching_choices.size,
      details: choice_details,
      selected_choice_id: matching_choices.first.id
    }
  end

  def create_choice(short_name)
    choice = Choice.new(
      catalog: catalog,
      choice_set: choice_set,
      parent_id: nil
    )

    # Ensure the short_name is UTF-8 encoded
    short_name = short_name.to_s.force_encoding('UTF-8')

    # Set the short_name for the specified locale
    choice.public_send("short_name_#{locale}=", short_name)

    # The validation requires short_name for all valid locales of the catalog.
    # We need to set the short_name for all valid locales to satisfy validation.
    # Use the same name as fallback for all locales.
    catalog.valid_locales.each do |valid_locale|
      locale_sym = valid_locale.to_sym
      next if locale_sym == locale # Already set above

      choice.public_send("short_name_#{locale_sym}=", short_name)
    end

    # Calculate position (last position + 1)
    choice.position = next_position

    choice.save!
    choice
  end

  # Create a new choice with translations in multiple locales
  def create_choice_i18n(names_by_locale)
    choice = Choice.new(
      catalog: catalog,
      choice_set: choice_set,
      parent_id: nil
    )

    # Set the short_name for all catalog locales
    # Use provided names where available, fallback to first provided name
    fallback_name = names_by_locale.values.first.to_s.force_encoding('UTF-8')
    catalog.valid_locales.each do |valid_locale|
      locale_sym = valid_locale.to_sym
      name = names_by_locale[locale_sym] || fallback_name
      # Ensure the name is UTF-8 encoded
      name = name.to_s.force_encoding('UTF-8')
      choice.public_send("short_name_#{locale_sym}=", name)
    end

    # Calculate position (last position + 1)
    choice.position = next_position

    choice.save!
    choice
  end

  # Calculate the next available position for a top-level choice
  def next_position
    (choice_set.choices.where(parent_id: nil).maximum(:position) || 0) + 1
  end

  # Normalize locale keys to symbols for consistency
  def normalize_locale_keys(locale_values)
    locale_values.transform_keys(&:to_sym)
  end
end
