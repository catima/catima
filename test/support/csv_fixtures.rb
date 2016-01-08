require "tempfile"

module CSVFixtures
  private

  def csv_file_with_data(data)
    file = Tempfile.new(["test", ".csv"])
    file.write(data)
    file.rewind
    file
  end
end
