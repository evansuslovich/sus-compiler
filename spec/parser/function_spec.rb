require "spec_helper"
require "parser/parser"


RSpec.describe Parser::Function do

  describe "Function" do
    context "#initialize" do
      it "successfully validates" do


        function = <<~CODE
        print_result(result) {
              print(result)
           }
        CODE

        tokenized_function = Lexer.scan(function)
        function = Parser::Function.new(tokenized_function)

        expect(function.view).to include("def print_result(result)")
        expect(function.view).to include("puts result")
        expect(function.view).to include("end")
      end
    end
  end
end
