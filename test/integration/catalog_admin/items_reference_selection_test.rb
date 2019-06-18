require "test_helper"

class CatalogAdmin::ItemReferenceSelectionTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "search without filter" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    within("#item_one_author_collaborator_uuid_json-editor", :wait => 30) do
      find("input").set("stephen")
    end

    assert(find("#item_one_author_collaborator_uuid_json-editor").has_text?("King", :count => 1))
    refute(find("#item_one_author_collaborator_uuid_json-editor").has_text?("Old"))
  end

  # rubocop:disable Metrics/BlockLength
  test "search with filters" do
    filters_and_associated_text = {
      :boolean => {
        :filter_name => 'Deceased',
        :text_to_enter => 'yes',
        :text_that_should_display => 'Old'
      },
      :choice_set => {
        :filter_name => 'Language',
        :text_to_enter => 'spani',
        :text_that_should_display => 'Spanish'
      },
      :date_time => {
        :filter_name => 'Born',
        :text_to_enter => '21',
        :text_that_should_display => 'September'
      },
      :decimal => {
        :filter_name => 'Rank',
        :text_to_enter => '1.',
        :text_that_should_display => '1.88891'
      },
      :editor => {
        :filter_name => 'Editor',
        :text_to_enter => 'one',
        :text_that_should_display => 'one-user@example.com'
      },
      :email => {
        :filter_name => 'Email',
        :text_to_enter => 'sk',
        :text_that_should_display => 'sk@stephenking.com'
      },
      :integer => {
        :filter_name => 'Age',
        :text_to_enter => 'old',
        :text_that_should_display => '2456'
      },
      :reference => {
        :filter_name => 'Collaborator',
        :text_to_enter => 'Stephen',
        :text_that_should_display => 'Very Old'
      },
      :text => {
        :filter_name => 'Nickname',
        :text_to_enter => 'Steve',
        :text_that_should_display => 'Stephen King'
      },
      :url => {
        :filter_name => 'Site',
        :text_to_enter => 'Stephen',
        :text_that_should_display => 'index.html'
      }
    }

    log_in_as("one-admin@example.com", "password")
    author = items(:one_author_stephen_king)

    filters_and_associated_text.each do |_item_type, test_elements|
      visit("/one/en/admin/authors/#{author.to_param}/edit")

      sleep 1
      within("#item_one_author_collaborator_uuid_json-filters") do
        find(".css-vj8t7z").click # Click on the filter input
        sleep 1

        within(".css-11unzgr") do # Within the filter list
          find('div', text: test_elements[:filter_name], match: :first).click
        end
      end

      within("#item_one_author_collaborator_uuid_json-editor") do
        find("input").set(test_elements[:text_to_enter])
      end

      assert(find("#item_one_author_collaborator_uuid_json-editor").has_text?(test_elements[:text_that_should_display]))
      sleep 1
    end
  end

  test "displays the first items with no pagination when there are less than 25 items loaded" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    find("#item_one_author_collaborator_uuid_json-editor", :wait => 30).click
    assert(find("#item_one_author_collaborator_uuid_json-editor").has_text?("King", :count => 1, :wait => 30))
  end

  test "displays all the unpaginated items" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    find("#item_one_author_collaborator_uuid_json-editor", :wait => 30).click
    assert(page.has_css?("#item_one_author_collaborator_uuid_json-editor div[role=\"option\"]", :count => 6))
  end

  test "displays the items after a filter has been selected and deselected" do
    log_in_as("one-admin@example.com", "password")

    author = items(:one_author_stephen_king)
    visit("/one/en/admin/authors/#{author.to_param}/edit")

    sleep 2 # Wait for Ajax request to complete

    find("#item_one_author_collaborator_uuid_json-editor").click
    assert(find("#item_one_author_collaborator_uuid_json-editor").has_text?("King", :count => 1))

    find("#item_one_author_collaborator_uuid_json-filters").click
    within(".css-11unzgr") do # Within the filter list
      sleep 1
      find('div', text: "Age", match: :first).click
    end

    find("#item_one_author_collaborator_uuid_json-editor").click
    assert(find("#item_one_author_collaborator_uuid_json-editor").has_text?("King", :count => 1))
  end
  # rubocop:enable Metrics/BlockLength
end
