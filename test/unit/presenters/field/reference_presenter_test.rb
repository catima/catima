require "test_helper"

class Field::ReferencePresenterTest < ActionView::TestCase
  include FieldsHelper
  include ItemsHelper
  include JsonHelper

  test "#value" do
    author = items(:one_author_stephen_king)
    collaborator = items(:one_author_very_old)
    collaborator_field = Field.find ActiveRecord::FixtureSet.identify('one_author_collaborator')
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_collaborator_uuid"] = collaborator.id

    presenter = Field::ReferencePresenter.new(self, author, collaborator_field)
    assert_equal(
      %Q(<a href="/one/en/authors/#{collaborator.id}-very-old">Very Old</a>),
      presenter.value
    )
  end

  test "#value for multiple" do
    author = items(:one_author_stephen_king)
    collaborators_field = Field.find ActiveRecord::FixtureSet.identify('one_author_other_collaborators')
    ids = [
      items(:one_author_very_old),
      items(:one_author_very_young)
    ].map { |i| i.id.to_s }
    # Have to set this manually because fixture doesn't know IDs ahead of time
    author.data["one_author_other_collaborators_uuid"] = ids

    presenter = Field::ReferencePresenter.new(self, author, collaborators_field)
    assert_equal(
      %Q(<a href="/one/en/authors/#{ids.first}-very-old">Very Old</a>, ) +
      %Q(<a href="/one/en/authors/#{ids.second}-very-young">Very Young</a>),
      presenter.value
    )
  end

  test "#value renders a link when referenced item is approved in a reviewed catalog" do
    item = items(:reviewed_book_referencing_approved)
    related_field = Field.find ActiveRecord::FixtureSet.identify('reviewed_book_related_book')
    result = Field::ReferencePresenter.new(self, item, related_field).value

    assert_includes result, "<a href="
    assert_includes result, items(:reviewed_book_finders_keepers_approved).id.to_s
    assert_not_includes result, "text-muted"
  end

  test "#value renders a grayed-out non-clickable span when referenced item is pending in a reviewed catalog" do
    item = items(:reviewed_book_referencing_pending)
    related_field = Field.find ActiveRecord::FixtureSet.identify('reviewed_book_related_book')
    result = Field::ReferencePresenter.new(self, item, related_field).value

    assert_not_includes result, "<a href="
    assert_includes result, '<span class="text-muted"'
    assert_includes result, "Harry Potter (book)"
  end

  test "#value renders a grayed-out non-clickable span when referenced item is not-ready in a reviewed catalog" do
    item = items(:reviewed_book_referencing_not_ready)
    related_field = Field.find ActiveRecord::FixtureSet.identify('reviewed_book_related_book')
    result = Field::ReferencePresenter.new(self, item, related_field).value

    assert_not_includes result, "<a href="
    assert_includes result, '<span class="text-muted"'
    assert_includes result, "End of Watch (book)"
  end
end
