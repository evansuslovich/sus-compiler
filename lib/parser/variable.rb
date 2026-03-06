module Parser
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
end
