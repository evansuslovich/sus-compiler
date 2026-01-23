module Lexer
  def self.tokenize_file(file_path)
    begin
      content = File.read(file_path)
      content.split(/[()\s]+/).reverse
    rescue => error
      raise error
    end
  end
end
