require "spec_helper"
require "parser/parser"

RSpec.describe Parser::Parameters do
  context "successfully" do
    context "initializes" do
      it "parameter with string" do
        parameters = Parser::Parameters.new("a,b")
        expected_parameters = ["a", "b"]
        expect(parameters.values).to eq(expected_parameters)
      end

      it "parameter with array" do
        parameters = Parser::Parameters.new(["a", "b"])
        expected_parameters = ["a", "b"]
        expect(parameters.values).to eq(expected_parameters)
      end
    end
    it "views" do
      parameters = Parser::Parameters.new(["a", "b"])
      expected_views = "a, b"
      expect(parameters.view).to eq(expected_views)
    end
  end
end
