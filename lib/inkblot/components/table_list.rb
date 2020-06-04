module Inkblot
  module Components
    # Shows a table of line entries, usually to describe what the side buttons do,
    # but also useful for list enumeration
    class TableList < Component
      # Creates default items if none exist
      def initialize(*args)
        super

        unless options.key?(:items)
          options[:items] = Array.new(4) { |x| "Key #{x}" }
        end
      end

      # Sugar to get to the items
      def items
        options[:items]
      end

      private

      # Allows for border size, and sets height and width standardly
      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        dta.border_size = options.fetch(:border_size, 0)

        dta.to_h
      end
    end
  end
end
