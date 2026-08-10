module Parser
  require_relative "variable"
  require_relative "parameters"
  require_relative "function"
  require_relative "built-in/function"
  require_relative "parse_tree"

  class CallExpression
    attr_reader :function_name, :params

    def initialize(function_name:, params:)
      @function_name = function_name
      @params = params.gsub('"', "")
    end

    def view
      puts "#{function_name}(#{params})"
    end


    private

    def format_params
      formatted_params = ""
      code_block.each do |code|
        formatted_code_block << code.view
        formatted_code_block << "\n" unless code == code_block.last
      end
      formatted_code_block
    end

  end

  def self.ruby_keywords
    ["__ENCODING__", "__LINE__", "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else", "elsif", "end", "ensure", "false", "for", "if","in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super", "then", "true", "undef", "unless", "until", "when", "while", "yield"]
  end

  def self.analyze(content)
    symbol_tree = {}
    # these differ in number regex, number_regex takes any number
    code = []

    line_of_code = content.last
    token = line_of_code.pop

    while content.length > 0

      case (token)
      when "function"
        # create function object
        function = Function.new(content)
        # add to symbol_tree
        symbol_tree[function.name] = function
        # add this to the code
        code << function

      when *symbol_tree.keys
        line_of_code = content.pop
        elements = Parser.elements_in_parentheses(line_of_code)
        parameters = Parser::Parameters.new(elements)

        code << CallExpression.new(function_name: token, params: parameters.view)

      else
        # Instatiating a new variable?
        line_of_code = content.pop
        equals_operator = line_of_code.pop
        if equals_operator != "="
          raise SyntaxError, "Expecting = after variable name"
        end

        node = Parser::ParseTree.parse(line_of_code, symbol_tree)
        variable = Parser::Variable.new(token, node.compute)

        symbol_tree[variable.name] = variable
        code << variable
      end

      break if content.size == 0
      token = content.last.pop
    end

    code
  end
end
