require "spec_helper"
require "parser/parser"

RSpec.describe Parser::Parser do

  describe "Variable" do
    it "fails when variable is a ruby_keyword" do
      Parser.ruby_keywords.each do |ruby_keyword|
        expect { Parser::Variable.new(ruby_keyword, nil) }.to raise_error(SyntaxError, "Unexpected reserved word, #{ruby_keyword}")
      end
    end

    it "initializes a variable" do
      variable = Parser::Variable.new("age", 22)
      expect(variable.name).to eq("age")
      expect(variable.value).to eq(22)
    end
  end

  describe ("Parameters") do
    it "initializes a parameter" do
      parameters = Parser::Parameters.new("a,b")
      expected_parameters = [Parser::Variable.new("a", nil), Parser::Variable.new("b", nil)]
      expect(parameters.arguments[0].name).to eq(expected_parameters[0].name)
      expect(parameters.arguments[0].value).to eq(expected_parameters[0].value)
      expect(parameters.arguments[1].name).to eq(expected_parameters[1].name)
      expect(parameters.arguments[1].value).to eq(expected_parameters[1].value)

    end
  end
end
