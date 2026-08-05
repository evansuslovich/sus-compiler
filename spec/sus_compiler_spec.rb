require "spec_helper"
require 'stringio'
require_relative '../lib/sus_compiler'

RSpec.describe SusCompiler do

	def capture_stdout
		old_stdout = $stdout
		$stdout = StringIO.new
		yield
		$stdout.string
	ensure
		$stdout = old_stdout
	end


	describe "#main" do
		context "runs on the given source file" do
      # I want to also run this in ruby and see the output but this is good enough for now
      it "print_vars.txt" do
				allow(ARGV).to receive(:[]).with(0).and_return("source/print_vars.txt")
				allow(ARGV).to receive(:[]).with(1).and_return("--output")

				output = capture_stdout { SusCompiler.main }

				expect(output).to include("def print_vars(a,b)")
				expect(output).to include("puts a")
				expect(output).to include("puts b")
				expect(output).to include("end")
				expect(output).to include("print_vars(1,2)")
			end

      it "add_numbers.txt" do
				allow(ARGV).to receive(:[]).with(0).and_return("source/add_numbers.txt")
				allow(ARGV).to receive(:[]).with(1).and_return("--output")

				output = capture_stdout { SusCompiler.main }

				expect(output).to include("def print_result(result)")
				expect(output).to include("puts result")
				expect(output).to include("end")
				expect(output).to include("result = 2")
				expect(output).to include("print_result(result)")
			end

      it "print_strings.txt" do
				allow(ARGV).to receive(:[]).with(0).and_return("source/print_strings.txt")
				allow(ARGV).to receive(:[]).with(1).and_return("--output")

				output = capture_stdout { SusCompiler.main }

				expect(output).to include("def print_result(result)")
				expect(output).to include('puts "the result is: "')
				expect(output).to include("puts result")
				expect(output).to include("end")
				expect(output).to include("result = 2")
				expect(output).to include("print_result(result)")
			end
		end
	end
end
