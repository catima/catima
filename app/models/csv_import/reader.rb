require "csv"

class CSVImport::Reader
  attr_reader :file, :contents
  delegate :encoding, :to => :contents

  def initialize(file)
    @file = file
    @contents = file.read
    guess_and_force_encoding
  end

  def rows
    @rows ||= CSV.parse(contents, :headers => true)
  end

  private

  def guess_and_force_encoding
    encodings = [contents.encoding, *possible_encodings].uniq

    found = encodings.find do |enc|
      contents.force_encoding(enc)
      begin
        %w(“ ” ‘ ’ … – —).any? { |c| contents.include?(c.encode(enc)) }
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
