require "test_helper"
require "open3"

class CatalogAdmin::ItemsControllerTest < ActiveSupport::TestCase
  setup do
    @upload_root = Rails.root.join("tmp", "test_uploads", SecureRandom.uuid)
    FileUtils.mkdir_p(@upload_root.join("upload", "catalog", "file-field"))
    FileUtils.mkdir_p(@upload_root.join("upload", "catalog", "image-field"))
    @tempfiles = []
  end

  teardown do
    @tempfiles.each(&:close!)
    FileUtils.rm_rf(@upload_root)
  end

  test "preserves a TIFF uploaded to a generic file field" do
    uploaded_file = uploaded_file_fixture("document.tiff", "image/tiff")
    field = Field::File.new

    result = with_public_path do
      CatalogAdmin::ItemsController.new.send(
        :process_uploaded_file,
        uploaded_file,
        field,
        "upload/catalog/file-field",
        "20260812000000"
      )
    end

    stored_file = @upload_root.join(result[:path])
    assert_equal ".tiff", stored_file.extname
    assert_equal "document.tiff", result[:name]
    assert_equal "image/tiff", result[:type]
    assert_equal "TIFF", image_format(stored_file)
  end

  test "converts a TIFF uploaded to an image field to JPEG" do
    uploaded_file = uploaded_file_fixture("picture.tiff", "image/tiff")
    field = Field::Image.new

    result = with_public_path do
      CatalogAdmin::ItemsController.new.send(
        :process_uploaded_file,
        uploaded_file,
        field,
        "upload/catalog/image-field",
        "20260812000000"
      )
    end

    stored_file = @upload_root.join(result[:path])
    assert_equal ".jpg", stored_file.extname
    assert_equal "picture.jpg", result[:name]
    assert_equal "image/jpeg", result[:type]
    assert_equal "JPEG", image_format(stored_file)
  end

  private

  def with_public_path
    original_public_path = Rails.method(:public_path)
    upload_root = Pathname.new(@upload_root)
    Rails.define_singleton_method(:public_path) { upload_root }
    yield
  ensure
    Rails.define_singleton_method(:public_path, original_public_path)
  end

  def uploaded_file_fixture(filename, content_type)
    # Create a temporary file whose extension determines the output format.
    tempfile = Tempfile.new(["upload", File.extname(filename)])
    # Keep track of the file so it can be removed after the test.
    @tempfiles << tempfile

    # Generate a small, valid image instead of writing fake bytes to the file.
    MiniMagick::Tool::Convert.new do |convert|
      convert.size "4x4"
      convert << "xc:red"
      convert << tempfile.path
    end

    # Wrap the file like the object Rails receives from a multipart upload.
    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: content_type
    )
  end

  def image_format(path)
    Open3.capture2("identify", "-format", "%m", path.to_s).first.strip
  end
end
