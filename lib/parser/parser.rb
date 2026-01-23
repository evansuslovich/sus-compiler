module Parser
  # https://docs.ruby-lang.org/en/master/syntax/keywords_rdoc.html

  class Variable
    attr_reader :name
    attr_accessor :value

    def initialize(name, value)
      if Parser.ruby_keywords.include?(name)
        raise SyntaxError, "Unexpected reserved word, #{name}"
      end

      @name = name
      @value = value
    end
  end


  class Parameters
    attr_reader :arguments

    def initialize(arguments)
      @arguments = validate(arguments)
    end

    private

    def validate(arguments)
      arguments = arguments.split(",").map do |argument|
        Variable.new(argument, nil)
      end
      arguments
    end


  end

  module BuiltIn
    module Function
      class Print
        attr_reader :argument

        def initialize(argument)
          raise ArgumentError if argument.nil?
          @argument = argument.gsub('"', "")
        end


        def view
          "puts #{argument}"
        end
      end
    end
  end

  class Function
    attr_reader :name, :parameters, :block

    def initialize(content)
      name, parameters, block = Function.validate(content)
      @name = name
      @parameters = parameters
      @block = block
    end

    class << self
      def validate(content)
        function_name = content.pop
        parameters = content.pop

        function_name = validate_function_name(function_name)
        parameters = validate_parameters(parameters)
        code_block = validate_code_block(content)
        return function_name, parameters, code_block
      end

      private

      def validate_function_name(function_name)
        raise SyntaxError if function_name.nil? || Parser.ruby_keywords.include?(function_name)
        function_name
      end

      def validate_parameters(parameters)
        raise SyntaxError if parameters.nil?

        Parameters.new(parameters)
      end

      def validate_code_block(code_block)
        starting_bracket = code_block.pop
        raise SyntaxError unless starting_bracket == "{"

        code_line = code_block.pop
        content = []

        while code_line != "}" do
          if code_line == "print"
            argument = code_block.pop
            content.append(BuiltIn::Function::Print.new(argument))
          else
            raise SyntaxError
          end
          code_line = code_block.pop
        end
        content
      end
    end
  end

  class CallExpression
    attr_reader :function_name, :code_block, :parameters, :arguments

    def initialize(function_name:, code_block:, parameters:, arguments:)
      require 'pry'; binding.pry
      @function_name = function_name
      @code_block = code_block
      @arguments = arguments.split(",")
    end
  end

  RUBY_KEYWORDS = Set["__ENCODING__", "__LINE__", "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else", "elsif", "end", "ensure", "false", "for", "if","in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super", "then", "true", "undef", "unless", "until", "when", "while", "yield"]

  def self.ruby_keywords
    RUBY_KEYWORDS
  end

  def self.analyze(content)
    symbol_tree = {}
    calls = []

    token = content.pop
    while content.length > 0

      case (token)
      when "function"
        function = Function.new(content)
        symbol_tree[function.name] = function
      when *symbol_tree.keys
        arguments = content.pop
        symbol = symbol_tree[token]

        calls.append(function_name: token, code_block: symbol.block, parameters: symbol.parameters, arguments: arguments)
      else
        raise SyntaxError
      end
      token = content.pop
    end

    calls
  end
end
