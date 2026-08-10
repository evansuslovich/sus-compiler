module Lexer
  class << self
    def tokenize_file(file_path)
      begin
        content = File.read(file_path)
        scan(content)
      rescue => error
        raise error
      end
    end

    def scan(content)
      content.scan(/.+/).map {
        |c| c.scan(/"[^"]*"|[()]|[^\s()]+/).reverse
      }.reverse
    end
  end
end
