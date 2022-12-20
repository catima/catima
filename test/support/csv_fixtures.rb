require "tempfile"

module CSVFixtures
  private

  def csv_file_with_data(data, encoding: 'ascii-8bit')
    file = Tempfile.new(["test", ".csv"], encoding: encoding)
    file.write(data)
    file.rewind
    file
  end
end
