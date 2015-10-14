class Field::Text < ::Field
  store_accessor :options, :maximum
  store_accessor :options, :minimum

  # TODO: validate minimum is less than maximum?

  validates_numericality_of :maximum, :minimum,
                            :only_integer => true,
                            :greater_than => 0,
                            :allow_blank => true

  # TODO: move this to superclass?
  validate :default_value_passes_field_validations

  # This can eventually be used to define validation rules for the dynamically-
  # generated Item class.
  def define_validators(field, attr)
    [length_validator(field, attr)].compact
  end

  private

  def default_value_passes_field_validations
    define_validators(self, :default_value).each do |validator|
      validator.validate(self)
    end
  end

  def length_validator(field, attr)
    opts = { :attributes => attr, :allow_blank => true }
    opts[:maximum] = field.maximum.to_i if field.maximum.to_i > 0
    opts[:minimum] = field.minimum.to_i if field.minimum.to_i > 0
    ActiveModel::Validations::LengthValidator.new(opts) if opts.size > 2
  end
end
