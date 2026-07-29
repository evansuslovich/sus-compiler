module Parser
  require_relative "parameters"

  class Parameters
    attr_reader :values

    def initialize(values)
      @values = values.split(",")
    end


    def view()
      format(@values)
    end


    private

    def format(arguments)
      formatted_arguments = ""
      arguments.each do |argument|
        formatted_arguments << argument
        formatted_arguments << ", " unless argument == arguments.last
      end
      formatted_arguments
    end
  end
end
