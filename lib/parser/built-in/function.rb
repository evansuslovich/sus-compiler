module Parser
  module BuiltIn
    module Function
      class Print
        attr_reader :argument

        def initialize(argument)
          if argument.nil?
            raise ArgumentError
          end
          @argument = argument
        end

        def view
          "puts #{argument}"
        end
      end
    end
  end
end
