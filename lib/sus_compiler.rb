class SusCompiler

  require_relative "lexer/lexer"
  require_relative "parser/parser"


  def self.main
    content = Lexer.tokenize_file(ARGV[0])
    print_output = ARGV[1] == "--output"
    all_code = Parser.analyze(content)

    if print_output
      all_code.each do |code|
        puts code.view
      end
    end
  end
end

SusCompiler.main if __FILE__ == $PROGRAM_NAME
