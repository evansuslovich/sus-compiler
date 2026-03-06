module Parser
  require_relative "parameters"

  class Parameters
    attr_reader :arguments

    def initialize(arguments)
      @arguments = validate(arguments)
    end

    private

    def validate(arguments)
      arguments = arguments.split(",").map do |argument|
        Parser::Variable.new(argument, nil)
      end
      arguments
    end
  end
end
