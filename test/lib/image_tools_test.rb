require "test_helper"

class ImageToolsTest < ActiveSupport::TestCase
  test "returns false and removes partial output when JPEG conversion fails" do
    source = Tempfile.new(["source", ".heic"])
    destination = Rails.root.join("tmp", "failed-image-conversion.jpg")
    destination.binwrite("partial output")

    MiniMagick::Image.expects(:open).with(source.path)
                     .raises(MiniMagick::Error, "unsupported format")
    Rails.logger.stubs(:warn)

    result = ImageTools.convert_to_jpeg(source.path, destination)

    assert_not result
  ensure
    # Close and remove the temporary source file even if the test fails.
    source&.close!
  end
end
