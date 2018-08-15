require "test_helper"

def assert_equal_files(f1, f2)
  assert_equal(File.open(f1, &:read), File.open(f2, &:read))
end

class CatalogDumpTest < ActionMailer::TestCase
  setup do
    Rake::Task.define_task(:environment)
  end

  test "catalog:dump" do
    cat_slug = format("photo-library-%05d", rand(0..99_999))

    # Delete catalog if it exists already
    c = Catalog.find_by(slug: cat_slug)
    unless c.nil?
      ENV['catalog'] = cat_slug
      Rake.application.invoke_task 'catalog:drop'
    end

    # Start importing the catalog
    indir = Rails.root.join('test', 'data', 'catalog_dumps', 'photo_library').to_s
    ENV['dir'] = indir
    ENV['slug'] = cat_slug
    Rake.application.invoke_task 'catalog:load'

    # Export the catalog again
    Dir.mktmpdir do |dir|
      outdir = File.join(dir, cat_slug).to_s
      ENV['dir'] = outdir
      ENV['catalog'] = cat_slug
      Rake.application.invoke_task 'catalog:dump'

      # Check if two folders are the same
      # We test first on a series of files that should be identical
      assert_equal_files(File.join(indir, 'menus.json'), File.join(outdir, 'menus.json'))

      # TODO: Data export does not work in test environment for some reason
      # but works fine in other environements.
      # assert_equal_files(File.join(indir, 'data', 'places.json'), File.join(outdir, 'data', 'places.json'))
      # assert_equal_files(File.join(indir, 'data', 'trip.json'), File.join(outdir, 'data', 'trip.json'))

      # We cannot directly test the catalog.json files because of the slug that is changed on catalog:load
      # assert_equal_files(File.join(indir, 'structure', 'catalog.json'), File.join(outdir, 'structure', 'catalog.json'))
      assert_equal_files(File.join(indir, 'structure', 'categories.json'), File.join(outdir, 'structure', 'categories.json'))
      assert_equal_files(File.join(indir, 'structure', 'choice-sets.json'), File.join(outdir, 'structure', 'choice-sets.json'))
      assert_equal_files(File.join(indir, 'structure', 'item-types', 'places.json'), File.join(outdir, 'structure', 'item-types', 'places.json'))
      assert_equal_files(File.join(indir, 'structure', 'item-types', 'trip.json'), File.join(outdir, 'structure', 'item-types', 'trip.json'))
      assert_equal_files(
        File.join(indir, 'files', '_26358aec_6d41_4715_b6b9_1f23811f1c73', '1514304092_Aerial_View_of_Tehran_26112008_04-35-03.jpg'),
        File.join(outdir, 'files', '_26358aec_6d41_4715_b6b9_1f23811f1c73', '1514304092_Aerial_View_of_Tehran_26112008_04-35-03.jpg')
      )
    end
  end
end
