require "spec_helper"
require "lexer/lexer"

RSpec.describe Lexer do


  context "tokenizes" do
    it "print_vars.txt" do
      content = Lexer.tokenize_file("source/print_vars.txt")
      expected_content = [")", "1,2", "(", "print_vars", "}", ")", "b", "(", "print", ")", "a", "(", "print", "{", ")", "a,b", "(", "print_vars", "function"]
      expect(content).to eq(expected_content)
    end

    it "add_numbers.txt" do
      content = Lexer.tokenize_file("source/add_numbers.txt")
      expected_content = [")", "result", "(", "print_result", "1", "-", "2", "+","1", "=", "result", "}", ")", "result", "(", "print", "{", ")", "result", "(", "print_result", "function"]
      expect(content).to eq(expected_content)
    end

    it "print_strings.txt" do
      content = Lexer.tokenize_file("source/print_strings.txt")
      expected_content =
        [")", "result", "(", "print_result", "1", "-", "2", "+", "1", "=",
         "result", "}", ")", "result", "(", "print", ")", "\"the result is: \"",
         "(", "print", "{", ")", "result", "(", "print_result", "function"]
      expect(content).to eq(expected_content)
    end

  end

  it "raises an error when file doesn't exist" do
    expect { Lexer.tokenize_file("file_does_not_exist.txt") }.to raise_error(Errno::ENOENT)
  end
end
