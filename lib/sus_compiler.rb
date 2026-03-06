class SusCompiler

  require_relative "lexer/lexer"
  require_relative "parser/parser"

  module Print
    def self.format_arguments(arguments)
      formatted_arguments = ""
      arguments.each do |argument|
        formatted_arguments << argument.name
        formatted_arguments << ", " unless argument == arguments.last
      end
      formatted_arguments
    end


    # this is fine
    def self.format_code_block(code_block)
      formatted_code_block= ""
      code_block.each do |code|
        formatted_code_block << code.view
        formatted_code_block << "\n" unless code == code_block.last
      end
      formatted_code_block
    end

    # this is so fcnk mechanical
    def self.handle_print_vars(call)
      <<~RUBY
        def #{call[:function_name]}(#{format_arguments(call[:parameters].arguments)})
          #{self.format_code_block(call[:code_block])}
          end

        #{call[:function_name]}(#{call[:arguments]})
      RUBY
    end

  end





  def self.main()
    content = Lexer.tokenize_file(ARGV[0])
    calls = Parser.analyze(content)

    # this is a huge work in progress!!!
    # squishing
    calls.each do |call|

      generated_code = if call[:function_name]== "print_vars"
        Print.handle_print_vars(call)
      end
      puts generated_code
    end
  end
end

SusCompiler.main
