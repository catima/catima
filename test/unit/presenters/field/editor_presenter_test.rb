require "test_helper"

class Field::EditorPresenterTest < ActionView::TestCase
  test "compact #value" do
    book = items(:one_book_finders_keepers)
    name_field = Field.find ActiveRecord::FixtureSet.identify('editor_field_with_updater')
    presenter = Field::EditorPresenter.new(self, book, name_field, style: :compact)
    assert_includes("Created by #{book.creator.email}", presenter.value)
    refute_includes("Updated by", presenter.value)
  end

  test "#value" do
    book = items(:one_book_finders_keepers)
    name_field = Field.find ActiveRecord::FixtureSet.identify('editor_field_with_updater')
    presenter = Field::EditorPresenter.new(self, book, name_field)
    assert_includes(presenter.value, "Created by #{book.creator.email}")
    assert_includes(presenter.value, "Updated by #{book.updater.email}")
  end
end
