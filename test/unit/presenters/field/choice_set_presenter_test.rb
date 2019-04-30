require "test_helper"

class Field::ChoiceSetPresenterTest < ActionView::TestCase
  include ItemsHelper

  test "#value" do
    author = items(:one_author_stephen_king)
    english = choices(:one_english)
    language_field = Field.find ActiveRecord::FixtureSet.identify('one_author_language')
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_language_uuid"] = english.id

    presenter = Field::ChoiceSetPresenter.new(self, author, language_field)
    assert_equal(
      '<a data-toggle="tooltip" data-placement="top" title="" href="/one/en/authors?language=en-Eng">English</a>',
      presenter.value
    )
  end

  test "#value for multiple" do
    author = items(:one_author_stephen_king)
    choices = [choices(:one_english), choices(:one_spanish)]
    languages_field = Field.find ActiveRecord::FixtureSet.identify('one_author_other_languages')
    # Have to set this manually because fixture doesn't know IDs ahead of time
    author.data["one_author_other_language_uuid"] = choices.map(&:id)

    presenter = Field::ChoiceSetPresenter.new(self, author, languages_field)
    assert_equal(
      '<a data-toggle="tooltip" data-placement="top" title="" href="/one/en/authors?other-language=en-Eng"'\
      '>English</a>, '\
      '<a data-toggle="tooltip" data-placement="top" title="" href="/one/en/authors?other-language=en-Spanish"'\
      '>Spanish</a>',
      presenter.value
    )
  end
end
