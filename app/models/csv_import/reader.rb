require "csv"

# Part of the CSV import process is reading the contents of a CSV file and
# parsing it into rows, which each row behaving like a Hash of header => value.
# This class encapsulates that logic and also handles guessing the character
# encoding of the CSV file, which can vary based on what application is used
# to generate the CSV.
#
class CSVImport::Reader
  attr_reader :file, :contents

  delegate :encoding, :to => :contents

  def initialize(file, specified_encoding=nil)
    @file = file
    @contents = file.read

    if specified_encoding
      contents.force_encoding(specified_encoding)
    else
      detect_and_force_encoding
    end

    # If the file is UTF-16LE, we need to convert it to UTF-8 for CSV parsing.
    @contents = contents.encode("UTF-8") if contents.encoding == Encoding::UTF_16LE

    # Strip the BOM if present, since it can interfere with CSV parsing.
    @contents = CSVImport::EncodingDetector.strip_bom(@contents)
  end

  # Parses the CSV file into an Array of rows. Each row is a Hash-like object
  # of header => value.
  def rows
    @rows ||= CSV.parse(contents, :headers => true)
  end

  private

  def detect_and_force_encoding
    result = CSVImport::EncodingDetector.detect_from_string(contents)
    encoding = result[:encoding]
    encoding = CSVImport::ENCODINGS.first if encoding == "unknown"
    contents.force_encoding(encoding)
  end
end
