require "spec_helper"
require "lexer/lexer"

RSpec.describe Lexer do

  it "tokenizes a file" do
    content = Lexer.tokenize_file("source/print_vars.txt")
    expected_content = ["function", "print_vars", "a,b", "{", "print", "a", "print", "b", "}", "print_vars", "a,b"]

    expect(content).to eq(expected_content)
  end

  it "raises an error when file doesn't exist" do
    expect { Lexer.tokenize_file("file_does_not_exist.txt") }.to raise_error(Errno::ENOENT)
  end
end
