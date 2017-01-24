require "test_helper"

class Field::ReferencePresenterTest < ActionView::TestCase
  include FieldsHelper
  include ItemsHelper

  test "#value" do
    author = items(:one_author_stephen_king)
    collaborator = items(:one_author_very_old)
    collaborator_field = fields(:one_author_collaborator)
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
    collaborators_field = fields(:one_author_other_collaborators)
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
end
