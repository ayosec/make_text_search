module MakeTextSearch

  module SubstringsFilter
    extend self

    def substrings(word, min_length = 3)
      results = []
      for starts in 0..word.size
        started = word[starts..-1]
        for ends in min_length..started.size
          results << word[starts, ends]
        end
      end

      results
    end

    def apply_filter(record, value)
      value.gsub(/(\S+)/) { substrings($1).join(" ") }
    end
  end

  module StripHtmlFilter
    extend self

    def translate_html_entities!(value)
      # http://gist.github.com/582351
      @entities_map ||= File.read("#{File.dirname(__FILE__)}/html_entities.dat").split("\0").inject({}) {|hash, line| line = line.split(" ", 2); hash[line[0]] = line[1]; hash };

      value.gsub!(/&(\w+);/) { @entities_map[$1] || $1 } or value
    end

    def apply_filter(record, value)
      # TODO extracts the content for some attributes like alt, title and longdesc
      translate_html_entities! value.gsub(/<[^>]*>/, "")
    end
  end

end
