module Parser
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
end
