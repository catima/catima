require 'test_helper'

class ExportTest < ActiveSupport::TestCase
  should validate_presence_of(:user)
  should validate_presence_of(:catalog)
  should validate_inclusion_of(:category).in_array(%w(catima sql csv))
  should validate_inclusion_of(:status).in_array(%w(error processing ready))

  test "export ready" do
    export = exports(:one)
    assert(export.ready?)
    assert(export.validity?)
    assert(export.file?)
  end

  test "export error but valid" do
    export = exports(:one_error)
    refute(export.ready?)
    assert(export.validity?)
    refute(export.file?)
  end

  test "export expired" do
    export = exports(:one_expired)
    assert(export.ready?)
    refute(export.validity?)
    refute(export.file?)
  end

  test "csv options default to false" do
    export = exports(:one_csv)
    refute(export.with_catima_id)
    refute(export.use_slugs)
  end
end
