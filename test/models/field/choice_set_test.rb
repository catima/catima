require "test_helper"
require_relative "../../../app/models/field/choice_set.rb"

class Field::ChoiceSetTest < ActiveSupport::TestCase
  should validate_presence_of(:choice_set)

  test "doesn't allow choice set from different catalog" do
    choice_set_field = fields(:one_author_language)
    assert(choice_set_field.valid?)

    choice_set_field.choice_set = choice_sets(:two_languages)
    refute(choice_set_field.valid?)
  end
end
