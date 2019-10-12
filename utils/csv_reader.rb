# frozen_string_literal: true

#
#  Simple class for reading csv data
#
class CSVReader

  LINE_SEPARATOR = "\n".freeze
  ENCODING = "utf-8".freeze
  ENCODING_WITH_BOM = "bom|#{ENCODING}".freeze

  def read(path, has_header = true, separator = ',')
    string = File.read(path, encoding: ENCODING_WITH_BOM)
    parse(string, has_header, separator)
  end

  private

  def parse(string, has_header, separator)
    encoded_string = string.encode(ENCODING, universal_newline: true)
    parse_csv(encoded_string.squeeze(LINE_SEPARATOR).strip, has_header, separator)
  end

  def parse_csv(string, has_header, separator)
    result = []
    rows = string.split(LINE_SEPARATOR)
    columns_count = rows[0].split(separator).size
    header = has_header ? rows[0].split(separator).map {|v| v.strip} : Array(0..columns_count - 1)
    rows.each_with_index do |row, row_index|
      next if has_header && row_index == 0

      cells = row.split(separator).map { |v| v.strip }
      Asserts.assert_equal(cells.size, columns_count, "row is consistent with header")
      hash = Hash.new
      (0..columns_count - 1).each { |i| hash[has_header ? header[i] : i] = cells[i] }
      result.append(hash)
    end
    result
  end
end