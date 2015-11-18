require "test_helper"

class Field::ChoiceSetPresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    english = choices(:one_english)
    language_field = fields(:one_author_language)
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_language_uuid"] = english.id

    presenter = Field::ChoiceSetPresenter.new(self, author, language_field)
    assert_equal(
      '<a href="/one/en/authors?language=en-Eng">English</a>',
      presenter.value
    )
  end
end
