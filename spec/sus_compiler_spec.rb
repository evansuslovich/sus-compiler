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
		context "E2E tests" do
			it "runs on the given source file" do
				allow(ARGV).to receive(:[]).with(0).and_return("source/add_numbers.txt")
				allow(ARGV).to receive(:[]).with(1).and_return("--output")

				output = capture_stdout { SusCompiler.main }

				# I want to also run this in ruby and see the output but this is good enough for now
				expect(output).to include("def print_result(result)")
				expect(output).to include("puts result")
				expect(output).to include("end")
				expect(output).to include("result = 2")
				expect(output).to include("print_result(result)")
			end
		end
	end
end
