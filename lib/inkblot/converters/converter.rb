module Inkblot
  module Converters
    # Abstract class for converting content from one form to another
    class Converter
      # The passed object to convert
      attr_accessor :input

      # Shortcut for instantiating and getting the output of a converter
      def self.call(opts = {})
        new(opts).output
      end

      # Take in +input+ and any other args
      def initialize(opts = {})
        @input = opts.fetch(:input)
      end

      # Implemented on the superclass for consistency
      def convert!
        @output = convert
        self
      end

      # Child classes override to implement core behavior
      def convert
        @input
      end

      # The bmp file to display on the device
      # Override so that we can't call this without conversion
      def output
        return @output if @output

        convert!
        @output
      end
    end
  end
end
