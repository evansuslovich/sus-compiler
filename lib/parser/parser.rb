module Parser
  require_relative "variable"
  require_relative "parameters"
  require_relative "function"
  require_relative "built-in/function"

  class CallExpression
    attr_reader :function_name, :code_block, :parameters, :arguments

    def initialize(function_name:, code_block:, parameters:, arguments:)
      @function_name = function_name
      @code_block = code_block
      @arguments = arguments.split(",")
    end
  end

  # https://docs.ruby-lang.org/en/master/syntax/keywords_rdoc.html
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
