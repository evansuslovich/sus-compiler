module Parser
  module ParseTree
    # Addition and Subtraction Parse Tree
    # This is my very naive and simple implenetation without
    # too much reading because sometimes it's fun to reinvent
    # the wheel.
    #
    # Example: 1 + 2 - 1
    # We're going to add to each Node object from left to right
    #
    # Token "1"
    # Node.new(0, ar_op?, new Node(val: 1), right?)
    #
    # Token "+"
    # Node.new(0, +, new Node(val: 1), right?)
    #
    # Token "2"
    # Node.new(0, +, new Node(val: 1), new Nod(val: 2))
    #
    #
    # Ok, so we're interacting with a new arithemtic symbol: -
    # What do we do?
    # Naively, go to the left object
    # Token "-"
    # Node.new(val: 0,
    #          ar_op: +,
    #          left: new Node(ar_op: -, val: 1),
    #          right: new Nod(val: 2))
    #
    # Token "1"
    # Node.new(val: 0,
    #          ar_op: +,
    #          left: new Node(ar_op: -, val: 1, left: 1),
    #          right: new Nod(val: 2))
    #
    #
    #         0
    #         +
    #      1     2
    #      -
    #    1
    #
    #
    # My question, how much of ParseTree will be initialized
    # recursively and at what point? On each ar_op?
    #
    # Let's look at this again with fresh eyes:
    #
    #
    # 1 + 2 - 1
    #
    # Abstract Syntax Tree:
    # (_ 1 _)
    # (+ 1 _)
    # (+ 1 2)
    # - (+ 1 2) _
    # - (+ 1 2) 1
    #
    #
    #
    # Language & Grammar Rules:
    #
    # FUCK it, METAPROGRAM
    class ::String
      AR_OPS = ["+", "-"].freeze

      def ar_op?
        AR_OPS.any? { |ar_op| self == ar_op }
      end
    end

    class Node

      attr_accessor :ar_op
      attr_accessor :left
      attr_accessor :right


      def initialize(ar_op: nil, left: nil, right: nil)
        @ar_op = ar_op
        @left = left
        @right = right
      end


      def view
        puts "#{@val}"

        if @left
          puts "left:"
          @left.view
        end
        if @right
          puts "right:"
          @right.view
        end
      end


      def insert(val)
        # assuming the parser would have thrown an error if there was an issue
        if !ar_op? && val.ar_op?
          @ar_op = val
        elsif !left?
          @left = val
        elsif !right?
          @right = val
        else
          raise SyntaxError,
            "Tried inserting #{val} but object is already filled: ar_op: #{ar_op}, left: #{left}, right: #{right}"
        end
      end

      def ar_op?
        ar_op == "+" || ar_op == "-"
      end

      def left?
        !left.nil?
      end

      def right?
        !right.nil?
      end

      def filled?
        ar_op? && left? && right?
      end


      # is there a single number in the Node
      # result = 1
      # Node(ar_op: nil, left: 1, right: nil)
      def single?
        !ar_op? && left? && !right?

      end


      def equals_to?(other_node)
        if left.instance_of?(Parser::ParseTree::Node)
          return left.equals_to?(other_node.left)
        end
        # I currently don't think this is possible right now.
        if right.instance_of?(Parser::ParseTree::Node)
          return right.equals_to?(other_node.right)
        end

        left == other_node.left &&
          right == other_node.right &&
          ar_op == other_node.ar_op
      end


      def compute

        if single?
          return left
        end

        case ar_op
        when "+"
          if left.instance_of?(Parser::ParseTree::Node)
            return left.compute + right.to_i
          end
          return left.to_i + right.to_i
        when "-"
          if left.instance_of?(Parser::ParseTree::Node)
            return left.compute - right.to_i
          end
          return left.to_i - right.to_i
        else
          raise SyntaxError, "unsupported ar_op"
        end
      end
    end



    class << self
      CALC_REGEX = /\d+|[+\-*\/%]/.freeze
      NUMBER_REGEX= /^-?\d+(\.\d+)?$/.freeze

      # The algorithm:
      # Instatiate a ParseTree object

      def parse(content, symbol_tree = {})
        list_of_numbers_and_operators = []
        number_or_arithmetic_operator = content.pop
        node = ParseTree::Node.new()
        # It's safe to assume that a number will alternate with arithmetic operators:
        # Correct    (1 + 2 + 3)
        # Incorrect  (1 1 1 + 2)
        # Incorrect  (1 + + + 2)

        expecting_number = true

        while true
          if symbol_tree.keys.include?(number_or_arithmetic_operator)
            number_or_arithmetic_operator = symbol_tree[number_or_arithmetic_operator].value
          end
          expecting_number = validate(expecting_number: expecting_number, number_or_arithmetic_operator: number_or_arithmetic_operator, symbol_tree: symbol_tree)

          if node.filled?
            node = ParseTree::Node.new(left: node)
            node.insert(number_or_arithmetic_operator)
          else
            node.insert(number_or_arithmetic_operator)
          end

          break if end_parsing(content, symbol_tree)
          number_or_arithmetic_operator = content.pop
        end

        node
      end

      private

      def end_parsing(content, symbol_tree)
        # end parsing if:
        #  - not a number
        #  - not an arithmetic symbol
        #  - not a valid variable
        !CALC_REGEX.match?(content.last) && !is_valid_variable?(content.last, symbol_tree)
      end

      def validate(expecting_number:, number_or_arithmetic_operator:, symbol_tree:)
        if expecting_number
          if is_number?(number_or_arithmetic_operator, symbol_tree)
            return !expecting_number
          elsif !NUMBER_REGEX.match?(number_or_arithmetic_operator)
            return !expecting_number
          end
          raise SyntaxError, "Expecting an arithmetic symbol (+,-), received #{number_or_arithmetic_operator}"
        else
          if is_ar_op?(number_or_arithmetic_operator)
            return !expecting_number
          else
            raise SyntaxError, "Expecting an arithmetic symbol (+,-), received #{number_or_arithmetic_operator}"
          end
        end
      end

      # so hairy
      def is_number?(number_or_arithmetic_operator, symbol_tree)
        if NUMBER_REGEX.match?(number_or_arithmetic_operator) || is_valid_variable?(number_or_arithmetic_operator, symbol_tree)
          return true
        end
        raise SyntaxError, "Expecting a number, received #{number_or_arithmetic_operator}"
      end

      def is_valid_variable?(possible_variable, symbol_tree)
        variable = symbol_tree[possible_variable]

        !variable.nil? && NUMBER_REGEX.match?(variable.value)
      end

      def is_ar_op?(str)
        str == "+" || str == "-" || str == "*" || str == "/"
      end

    end
  end
end
