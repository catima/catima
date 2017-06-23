require "test_helper"

class Field::ComponentConfigTest < ActiveSupport::TestCase
  test "text field has no component choices" do
    field = fields(:one_title)
    config = Field::ComponentConfig.new(field)

    refute(config.component_choice?(:editor))
    refute(config.component_choice?(:display))
    assert_empty(config.component_choices(:editor))
    assert_empty(config.component_choices(:display))

    config.assign_default_components
    assert_nil(field.editor_component)
    assert_nil(field.display_component)
  end

  test "text field prohibits editor_component values" do
    field = fields(:one_title)
    config = Field::ComponentConfig.new(field)

    field.editor_component = "foo"
    config.validate_component(:editor)
    refute_empty(field.errors[:editor_component])
  end

  test "text field prohibits display_component values" do
    field = fields(:one_title)
    config = Field::ComponentConfig.new(field)

    field.display_component = "foo"
    config.validate_component(:display)
    refute_empty(field.errors[:display_component])
  end

  test "date_time field has one editor choice" do
    field = fields(:one_author_born)
    config = Field::ComponentConfig.new(field)

    refute(config.component_choice?(:editor))
    assert_equal(["DateTimeInput"], config.component_choices(:editor))
  end

  test "date_time automatically assigns default editor choice" do
    field = fields(:one_author_born)
    config = Field::ComponentConfig.new(field)

    config.assign_default_components
    assert_equal("DateTimeInput", field.editor_component)
  end

  test "field with multiple display components offers choices" do
    _, config = field_and_config_with_multiple_display_components

    assert(config.component_choice?(:display))
    assert_equal(%w(One Two Three), config.component_choices(:display))
  end

  test "field with multiple display components does not auto-assign choice" do
    field, config = field_and_config_with_multiple_display_components

    config.assign_default_components
    assert_nil(field.display_component)
  end

  test "field with multiple display components validates selection" do
    field, config = field_and_config_with_multiple_display_components

    field.display_component = "One"
    config.validate_component(:display)
    assert_empty(field.errors[:display_component])

    field.display_component = "Invalid"
    config.validate_component(:display)
    refute_empty(field.errors[:display_component])
  end

  private

  def field_and_config_with_multiple_display_components
    field = fields(:one_book_author)
    fake_config = {
      "Reference" => { "display_components" => %w(One Two Three) }
    }

    mock_loader = mock
    JsonConfig.stubs(:for_catalog).with(field.catalog).returns(mock_loader)
    mock_loader.stubs(:load).with("fields.json").returns(fake_config)

    [field, Field::ComponentConfig.new(field)]
  end
end
