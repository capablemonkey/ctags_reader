module CtagsReader
  # The Tag is the representation of each tag in the tags file. It can be
  # initialized manually by giving it its four components, but it can also be
  # created from a tab-delimited line from the file.
  #
  class Tag < Struct.new(:name, :filename, :ex_command, :type)
    def self.from_string(string)
      name, filename, ex_command, type = to_utf8(string).split("\t")
      new(name, filename, ex_command, type)
    end

    def line_number
      @line_number ||= calculate_line_number
    end

    private

    def calculate_line_number
      if ex_command.to_i > 0
        return ex_command.to_i
      end

      if not File.readable?(filename)
        return nil
      end

      # remove wrapping / and /;"
      pattern = ex_command.gsub(/^\//, '').gsub(/\/(;")?$/, '')

      # Escape the chars between ^ and $
      regex   = Regexp.new("^#{Regexp.escape(pattern[1..-2])}")

      # try to find line number from file
      File.open(filename, 'r') do |file|
        index = 1
        file.each_line do |line|
          return index if (regex =~ line) == 0
          index += 1
        end
      end

      # nil if not found:
      nil
    end
  end
end

def to_utf8(str)
  str = str.force_encoding("UTF-8")
  return str if str.valid_encoding?
  str = str.force_encoding("BINARY")
  str.encode("UTF-8", invalid: :replace, undef: :replace)
end
