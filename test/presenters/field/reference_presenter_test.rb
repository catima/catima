require "test_helper"

class Field::ReferencePresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    collaborator = items(:one_author_very_old)
    collaborator_field = fields(:one_author_collaborator)
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_collaborator_uuid"] = collaborator.id

    presenter = Field::ReferencePresenter.new(self, author, collaborator_field)
    assert_equal("Very Old", presenter.value)
  end
end
