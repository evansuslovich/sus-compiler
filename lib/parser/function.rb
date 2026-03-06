module Parser
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
end
