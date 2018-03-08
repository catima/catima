require "test_helper"

class CatalogLoadTest < ActionMailer::TestCase
  setup do
    Rake::Task.define_task(:environment)
  end

  test "catalog:load" do
    cat_slug = format("photo-library-%04d", rand(0..9999))

    # Delete catalog if it exists already
    c = Catalog.find_by(slug: cat_slug)
    unless c.nil?
      ENV['catalog'] = cat_slug
      Rake.application.invoke_taks 'catalog:drop'
    end

    # Start importing the catalog
    ENV['dir'] = Rails.root.join('test', 'data', 'catalog_dumps', 'photo_library').to_s
    ENV['slug'] = cat_slug
    Rake.application.invoke_task 'catalog:load'

    # Check the catalog exists
    c = Catalog.find_by(slug: cat_slug)
    assert_equal(c.name, "Photo library")
    assert_equal(c.item_types.count, 2)

    # Drop the catalog
    ENV['catalog'] = cat_slug
    Rake.application.invoke_task 'catalog:drop'
    c2 = Catalog.find_by(slug: cat_slug)
    assert_nil c2
  end
end
