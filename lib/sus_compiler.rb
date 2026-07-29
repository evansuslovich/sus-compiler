class SusCompiler

  require_relative "lexer/lexer"
  require_relative "parser/parser"


  def self.main
    require "pry"; binding.pry
    content = Lexer.tokenize_file(ARGV[0])
    print_output = ARGV[1] == "--output"
    require "pry"; binding.pry
    all_code = Parser.analyze(content)


    if print_output
      all_code.each do |code|
        puts code.view
      end
    end
  end
end

SusCompiler.main
