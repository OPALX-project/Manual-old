require 'asciidoctor'
require 'asciidoctor/extensions'

Asciidoctor::Extensions.register do
  preprocessor do
    process do |document, reader|
      lines = []
      stack = []

      reader.readlines.each_with_index do |line, idx|
        case line.strip
        when 'opal-begin', 'opalx-begin'
          kind = line.strip == 'opal-begin' ? 'opal' : 'opalx'
          stack << [kind, idx + 1]
          lines << "[.feature-#{kind}]"
          lines << '--'
        when 'opal-end', 'opalx-end'
          if stack.empty?
            raise %(Unmatched #{line.strip} marker at #{reader.file}:#{idx + 1})
          end

          expected_kind = line.strip == 'opal-end' ? 'opal' : 'opalx'
          actual_kind, start_line = stack.pop
          if actual_kind != expected_kind
            raise %(Mismatched #{line.strip} marker at #{reader.file}:#{idx + 1}; expected #{actual_kind}-end for block opened at line #{start_line})
          end

          lines << '--'
        else
          lines << line
        end
      end

      unless stack.empty?
        kind, line_no = stack.last
        raise %(Unclosed feature #{kind} block starting at #{reader.file}:#{line_no})
      end

      Asciidoctor::Reader.new lines, reader.file, document: document
    end
  end
end
