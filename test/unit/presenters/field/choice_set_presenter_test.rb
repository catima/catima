require "test_helper"

class Field::ChoiceSetPresenterTest < ActionView::TestCase
  include ItemsHelper

  test "#value" do
    author = items(:one_author_stephen_king)
    english = choices(:one_english)
    language_field = Field.find ActiveRecord::FixtureSet.identify('one_author_language')
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_language_uuid"] = [english.id.to_s]

    expected_html = <<~HTML
      <div>
        <div data-controller=\"hierarchy-revealable\">
          <div data-hierarchy-revealable-target=\"choice\">
            <a href=\"/one/en/authors?language=en-Eng\">English</a>
          </div>
          <div data-hierarchy-revealable-target=\"choice\" style=\"display: none\">
            <a href=\"/one/en/authors?language=en-Eng\">English</a>
            <span class=\"ps-2\" data-toggle=\"tooltip\" title=\"Hide hierarchy\" data-action=\"click-&gt;hierarchy-revealable#toggle\">
              <i class=\"fa fa-caret-left toggle-hierarchy\"></i>
            </span>
          </div>
        </div>
      </div>
    HTML

    presenter = Field::ChoiceSetPresenter.new(self, author, language_field)
    assert_equal(
      expected_html.gsub(/(\n\s*)+/, ''), # Remove LF and indentation.
      presenter.value
    )
  end

  test "#value with hierarchy" do
    author = items(:one_author_stephen_king)
    english_uk = choices(:one_english_uk)
    language_field = Field.find ActiveRecord::FixtureSet.identify('one_author_language')
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_language_uuid"] = [english_uk.id.to_s]

    expected_html = <<~HTML
      <div>
        <div data-controller=\"hierarchy-revealable\">
          <div data-hierarchy-revealable-target=\"choice\">
            <a href=\"/one/en/authors?language=en-Eng+%28UK%29\">English (UK)</a>
            <span class=\"ps-2\" data-toggle=\"tooltip\" title=\"Show hierarchy\" data-action=\"click-&gt;hierarchy-revealable#toggle\">
              <i class=\"fa fa-caret-right toggle-hierarchy\"></i>
            </span>
          </div>
          <div data-hierarchy-revealable-target=\"choice\" style=\"display: none\">
            <a href=\"/one/en/authors?language=en-Eng+%28UK%29\">English / English (UK)</a>
            <span class=\"ps-2\" data-toggle=\"tooltip\" title=\"Hide hierarchy\" data-action=\"click-&gt;hierarchy-revealable#toggle\">
              <i class=\"fa fa-caret-left toggle-hierarchy\"></i>
            </span>
          </div>
        </div>
      </div>
    HTML

    presenter = Field::ChoiceSetPresenter.new(self, author, language_field)
    assert_equal(
      expected_html.gsub(/(\n\s*)+/, ''), # Remove LF and indentation.
      presenter.value
    )
  end

  test "#value for multiple" do
    author = items(:one_author_stephen_king)
    choices = [choices(:one_english), choices(:one_spanish)]
    languages_field = Field.find ActiveRecord::FixtureSet.identify('one_author_other_languages')
    # Have to set this manually because fixture doesn't know IDs ahead of time
    author.data["one_author_other_language_uuid"] = choices.map(&:id)

    # rubocop:disable Layout/TrailingWhitespace -> trailing whitespaces present in html.
    expected_html = <<~HTML
      <div>
        <div data-controller=\"hierarchy-revealable\">
          <div data-hierarchy-revealable-target=\"choice\">
            <a href=\"/one/en/authors?other-language=en-Eng\">English</a>
          </div>
          <div data-hierarchy-revealable-target=\"choice\" style=\"display: none\">
            <a href=\"/one/en/authors?other-language=en-Eng\">English</a>
            <span class=\"ps-2\" data-toggle=\"tooltip\" title=\"Hide hierarchy\" data-action=\"click-&gt;hierarchy-revealable#toggle\">
              <i class=\"fa fa-caret-left toggle-hierarchy\"></i>
            </span>
          </div>
        </div> 
        <div data-controller=\"hierarchy-revealable\">
          <div data-hierarchy-revealable-target=\"choice\">
            <a href=\"/one/en/authors?other-language=en-Spanish\">Spanish</a>
          </div>
          <div data-hierarchy-revealable-target=\"choice\" style=\"display: none\">
            <a href=\"/one/en/authors?other-language=en-Spanish\">Spanish</a>
            <span class=\"ps-2\" data-toggle=\"tooltip\" title=\"Hide hierarchy\" data-action=\"click-&gt;hierarchy-revealable#toggle\">
              <i class=\"fa fa-caret-left toggle-hierarchy\"></i>
            </span>
          </div>
        </div>
      </div>
    HTML
    # rubocop:enable Layout/TrailingWhitespace

    presenter = Field::ChoiceSetPresenter.new(self, author, languages_field)
    assert_equal(
      expected_html.gsub(/(\n\s*)+/, ''), # Remove LF and indentation.
      presenter.value
    )
  end
end
