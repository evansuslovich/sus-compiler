module Parser

  module_function
  def elements_in_parentheses(content)
    opening_paran = content.pop

    if opening_paran != "("
      raise SyntaxError
    end

    parameter_or_closing_paran = content.pop

    list_of_params = []
    while parameter_or_closing_paran != ")"
      list_of_params << parameter_or_closing_paran
      parameter_or_closing_paran = content.pop
    end

    if parameter_or_closing_paran != ")"
      raise SyntaxError
    end

    list_of_params
  end

  class Function
    attr_reader :name, :parameters, :block

    def initialize(content)
      name, parameters, block = Function.validate(content)
      @name = name
      @parameters = parameters
      @block = block
    end

    def view
      <<~RUBY
        def #{@name}(#{(@parameters.view)})
          #{format_code_block(@block)}
          end
      RUBY
    end


    private

    def format_code_block(code_block)
      formatted_code_block = ""
      code_block.each do |code|
        formatted_code_block << code.view
        formatted_code_block << "\n" unless code == code_block.last
      end
      formatted_code_block
    end


    class << self
      def validate(content)

        function_name = validate_function_name(content)
        parameters = validate_parameters(content)
        code_block = validate_code_block(content)
        return function_name, parameters, code_block
      end

      private

      def validate_function_name(content)
        function_name = content.pop

        if function_name.nil? || Parser.ruby_keywords.include?(function_name)
          raise SyntaxError
        end

        function_name
      end

      def validate_parameters(content)
        Parameters.new(Parser.elements_in_parentheses(content))
      end

      def validate_code_block(code_block)
        starting_bracket = code_block.pop
        raise SyntaxError unless starting_bracket == "{"

        code_line = code_block.pop
        content = []

        while code_line != "}" do
          # it would be nice to have an abstract handler
          # I can't imagine the amount of functions that we have here?
          if code_line == "print"

            elements = Parser.elements_in_parentheses(code_block)
            parameters = Parser::Parameters.new(elements)
            # what happens if there are no argument
            content.append(BuiltIn::Function::Print.new(parameters.view))
          else
            raise SyntaxError
          end
          code_line = code_block.pop
        end
        content
      end
    end
  end
end
