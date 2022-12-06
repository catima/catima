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

  def initialize(file)
    @file = file
    @contents = file.read
    guess_and_force_encoding
  end

  # Parses the CSV file into an Array of rows. Each row is a Hash-like object
  # of header => value.
  def rows
    @rows ||= CSV.parse(contents, :headers => true)
  end

  private

  def guess_and_force_encoding
    encodings = [contents.encoding, *possible_encodings].uniq

    found = encodings.find do |enc|
      contents.force_encoding(enc)
      begin
        %w(“ ” ‘ ’ … – —).all? do |c|
          c.encode(enc) if contents.include?(c.clone.force_encoding(enc))
          true
        end
      rescue Encoding::UndefinedConversionError
        false
      end
    end

    contents.force_encoding(encodings.first) unless found
  end

  def possible_encodings
    %w(MacRoman Windows-1252 UTF-8 UTF-16LE).map do |enc|
      Encoding.find(enc)
    end
  end
end
