require "test_helper"

class React::ItemsExceptTest < ActionDispatch::IntegrationTest
  setup do
    @stephen_king = items(:one_author_stephen_king)
    @empty_author = items(:one_author_empty_fields)
  end

  BASE_URL = "/react/one/en/authors".freeze

  # ── Normal usage ──────────────────────────────────────────────────────────────

  test "returns all items when no except param is given" do
    get BASE_URL, as: :json

    assert_response :success
    ids = json_item_ids
    assert_includes ids, @stephen_king.id
    assert_includes ids, @empty_author.id
  end

  test "excludes a single item when its id is passed in except[]" do
    get BASE_URL, params: { except: [@stephen_king.id] }, as: :json

    assert_response :success
    ids = json_item_ids
    assert_not_includes ids, @stephen_king.id
    assert_includes     ids, @empty_author.id
  end

  test "excludes a single item when its id is passed as scalar except param" do
    get BASE_URL, params: { except: @stephen_king.id }, as: :json

    assert_response :success
    ids = json_item_ids
    assert_not_includes ids, @stephen_king.id
    assert_includes     ids, @empty_author.id
  end

  test "excludes multiple items when several ids are passed in except[]" do
    get BASE_URL, params: { except: [@stephen_king.id, @empty_author.id] }, as: :json

    assert_response :success
    ids = json_item_ids
    assert_not_includes ids, @stephen_king.id
    assert_not_includes ids, @empty_author.id
  end

  test "returns all items when except[] is empty" do
    get BASE_URL, params: { except: [] }, as: :json

    assert_response :success
    ids = json_item_ids
    assert_includes ids, @stephen_king.id
    assert_includes ids, @empty_author.id
  end

  # ── Security: SQL injection ───────────────────────────────────────────────────

  test "SQL injection attempt in except[] is neutralised and returns a normal response" do
    get BASE_URL, params: { except: ["1) OR 1=1--"] }, as: :json

    assert_response :success
    # All real items must still be present — injection has no effect
    ids = json_item_ids
    assert_includes ids, @stephen_king.id
    assert_includes ids, @empty_author.id
  end

  test "UNION-based injection attempt in except[] is neutralised" do
    get BASE_URL, params: { except: ["1) UNION SELECT 1,2,3--"] }, as: :json

    assert_response :success
    ids = json_item_ids
    assert_includes ids, @stephen_king.id
  end

  # ── Edge cases ────────────────────────────────────────────────────────────────

  test "non-integer values in except[] are ignored (mapped to 0, no real item has id=0)" do
    get BASE_URL, params: { except: ["abc", "not-an-id", ""] }, as: :json

    assert_response :success
    ids = json_item_ids
    assert_includes ids, @stephen_king.id
    assert_includes ids, @empty_author.id
  end

  test "except[] with a mix of valid ids and non-integer values only excludes valid ids" do
    get BASE_URL, params: { except: [@stephen_king.id, "not-an-id"] }, as: :json

    assert_response :success
    ids = json_item_ids
    assert_not_includes ids, @stephen_king.id  # valid id is excluded
    assert_includes     ids, @empty_author.id  # others remain
  end

  private

  def json_item_ids
    response.parsed_body.fetch("items", []).pluck("id")
  end
end
