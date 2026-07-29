require "spec_helper"
require "parser/parse_tree"

RSpec.describe Parser::ParseTree do

  describe Parser::ParseTree do

    context "successfully parses" do
      it "with even # of numbers" do
        content = ["1", "-", "2", "+", "3", "-", "4"]

        #         -
        #       /   \
        #      +     4
        #    /   \
        #   -     3
        #  / \
        # 1   2
        #


        # instatiating bottom-up:

        four_minus_three = Parser::ParseTree::Node.new(ar_op: "-", left: "4", right: "3")
        four_minus_three_plus_two = Parser::ParseTree::Node.new(ar_op: "+", left: four_minus_three, right: "2")
        four_minus_three_plus_two_minus_one = Parser::ParseTree::Node.new(ar_op: "-", left: four_minus_three_plus_two, right: "1")

        result = Parser::ParseTree.parse(content)

        expect(result.equals_to?(four_minus_three_plus_two_minus_one)).to be true
      end

      it "with odd # of numbers" do
        content = ["1", "-", "2", "+", "3"]
        #      +
        #    /   \
        #   -     3
        #  / \
        # 1   2
        #

        # instatiating bottom-up:
        three_plus_two = Parser::ParseTree::Node.new(ar_op: "+", left: "3", right: "2")
        three_plus_two_minus_one = Parser::ParseTree::Node.new(ar_op: "-", left: three_plus_two, right: "1")

        result = Parser::ParseTree.parse(content)
        expect(result.equals_to?(three_plus_two_minus_one)).to be true
      end

      it "with two numbers" do
        content = ["1", "-", "2"]
        #   -
        #  / \
        # 1   2::Node.
        # instatiating bottom-up:
        one_minus_two = Parser::ParseTree::Node.new(ar_op: "-", left: "2", right: "1")

        result = Parser::ParseTree.parse(content)
        expect(result.equals_to?(one_minus_two)).to be true
      end

      it "with one number" do
        content = ["1"]

        # does not create ParseTree and returns 1
        expect(Parser::ParseTree.parse(content)).to eq("1")
      end

    end

    context "fails" do
      it "when expecting number but received arithemtic_operator" do
        content = ["1", "-", "-", "+", "1"]

        expect { Parser::ParseTree.parse(content) }
          .to raise_error(SyntaxError, "Expecting a number, received -")
      end

      it "when expecting arithemtic_operator but received number" do
        content = ["1", "-", "1", "1", "1"]

        expect { Parser::ParseTree.parse(content) }
          .to raise_error(SyntaxError, "Expecting an arithmetic symbol (+,-), received 1")
      end
    end
  end

  describe Parser::ParseTree::Node do

    context "insert" do
      it "successfully inserts values based an Node's introspection" do
        node = Parser::ParseTree::Node.new()
        node.insert("1")
        expect(node.left).to eq("1")
        expect(node.right).to be_nil
        expect(node.ar_op).to be_nil

        node.insert("+")
        expect(node.left).to eq("1")
        expect(node.right).to be_nil
        expect(node.ar_op).to eq("+")

        node.insert("2")
        expect(node.left).to eq("1")
        expect(node.right).to eq("2")
        expect(node.ar_op).to eq("+")
      end


      it "successfully inserts ar_op on a filled node" do
        left = Parser::ParseTree::Node.new(ar_op: "-", left: "4", right: "3")
        node = Parser::ParseTree::Node.new(left: left)
        node.insert("+")



        expected_result = Parser::ParseTree::Node.new(
          ar_op: "+",
          left: Parser::ParseTree::Node.new(ar_op: "-", left: "4", right: "3"),
          right: nil)


        expect(node.equals_to?(expected_result)).to be true
      end

      it "throws an Error when trying to insert but Node is already filled" do
        node = Parser::ParseTree::Node.new()
        node.insert("1")
        node.insert("+")
        node.insert("2")
        expect(node.filled?).to be true

        expect { node.insert("-") }.to raise_error(SyntaxError, "Tried inserting - but object is already filled: ar_op: +, left: 1, right: 2")
      end
    end

    context"single?" do
      it "returns true when only left exists" do
        node = Parser::ParseTree::Node.new(left: 1)
        expect(node.single?).to be true
      end

      it "returns false when right exists" do
        node = Parser::ParseTree::Node.new(right: 2)
        expect(node.single?).to be false
      end

      it "returns false when left and right exists" do
        node = Parser::ParseTree::Node.new(left: 1, right: 2)
        expect(node.single?).to be false
      end

      it "returns false when filled? is true" do
        node = Parser::ParseTree::Node.new(ar_op: "+", left: 1, right: 2)
        expect(node.single?).to be false
      end
    end

    context "filled?" do
      it "returns true when entire object is filled" do
        node = Parser::ParseTree::Node.new(ar_op: "+", left: "1", right: "2")
        expect(node.filled?).to be true
      end

      it "returns false when entire left is empty" do
        node = Parser::ParseTree::Node.new(ar_op: "+", right: "2")
        expect(node.filled?).to be false
      end

      it "returns false when entire right is empty" do
        node = Parser::ParseTree::Node.new(ar_op: "+", left: "1")
        expect(node.filled?).to be false
      end

      it "returns false when entire ar_op is empty" do
        node = Parser::ParseTree::Node.new(ar_op: nil, left: "1", right: "2")
        expect(node.filled?).to be false
      end
    end

    context "equals_to?" do
      it "passes when both nodes are filled?" do
        node_a = Parser::ParseTree::Node.new(ar_op: "+", left: "1", right: "2")
        node_b = Parser::ParseTree::Node.new(ar_op: "+", left: "1", right: "2")

        expect(node_a.filled?).to be true
        expect(node_b.filled?).to be true
        expect(node_a.equals_to?(node_b)).to be true
      end

      it "passes when both nodes are single?" do
        node_a = Parser::ParseTree::Node.new(left: "1")
        node_b = Parser::ParseTree::Node.new(left: "1")

        expect(node_a.single?).to be true
        expect(node_b.single?).to be true
        expect(node_a.equals_to?(node_b)).to be true
      end

      it "passes when both nodes are nested" do
        # 1 + 2 - 3
        node_a_left = Parser::ParseTree::Node.new(ar_op: "+", left: "1", right: "2")
        node_a = Parser::ParseTree::Node.new(ar_op: "-", left: node_a_left, right: "3")

        node_b_left = Parser::ParseTree::Node.new(ar_op: "+", left: "1", right: "2")
        node_b = Parser::ParseTree::Node.new(ar_op: "-", left: node_b_left, right: "3")

        expect(node_a.filled?).to be true
        expect(node_b.filled?).to be true
        expect(node_a.equals_to?(node_b)).to be true
      end
    end

    context "compute" do
      context "mixed" do
        context "addition and subtraction" do
          it "when node is nested" do
            four_minus_three = Parser::ParseTree::Node.new(ar_op: "-", left: "4", right: "3")
            four_minus_three_plus_two = Parser::ParseTree::Node.new(ar_op: "+", left: four_minus_three, right: "2")
            four_minus_three_plus_two_minus_one = Parser::ParseTree::Node.new(ar_op: "-", left: four_minus_three_plus_two, right: "1")


            expect(four_minus_three_plus_two_minus_one.compute).to eq(2)
          end
        end
      end
      context "addition" do
        it "when node is nested" do
          # 1 + 2 + 3
          one_plus_two = Parser::ParseTree::Node.new(ar_op: "+", left: "1", right: "2")
          one_plus_two_plus_three = Parser::ParseTree::Node.new(ar_op: "+", left: one_plus_two, right: "3")

          expect(one_plus_two_plus_three.compute).to eq(6)
        end

        it "when node is filled?" do
          one_plus_two = Parser::ParseTree::Node.new(ar_op: "+", left: "1", right: "2")
          expect(one_plus_two.compute).to eq(3)
        end
      end

      context "subtraction" do
        it "when node is nested" do
          # 4 - 2 - 1
          four_minus_two = Parser::ParseTree::Node.new(ar_op: "-", left: "4", right: "2")
          four_minus_two_minus_one = Parser::ParseTree::Node.new(ar_op: "-", left: four_minus_two, right: "1")

          expect(four_minus_two_minus_one.compute).to eq(1)
        end

        it "when node is filled?" do
          four_minus_two = Parser::ParseTree::Node.new(ar_op: "-", left: "4", right: "2")
          expect(four_minus_two.compute).to eq(2)
        end
      end
    end
  end
end
