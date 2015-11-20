require "test_helper"

class ItemList::ReferencesTest < ActiveSupport::TestCase
  test "finds referencing items" do
    parent, child = parent_and_child_authors

    field = fields(:one_author_collaborator)
    references = ItemList::References.new(:item => parent, :field => field)
    results = references.items

    assert_equal(1, results.count)
    assert_includes(results.to_a, child)
  end

  private

  def parent_and_child_authors
    child_author = items(:one_author_stephen_king)
    parent_author = items(:one_author_very_old)
    # Have to set this manually because fixture doesn't know ID ahead of time
    child_author.data["one_author_collaborator_uuid"] = parent_author.id
    child_author.save!
    [parent_author, child_author]
  end
end
