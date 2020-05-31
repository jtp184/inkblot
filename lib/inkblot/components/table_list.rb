module Inkblot
  module Components
    # Shows a table of line entries, usually to describe what the side buttons do,
    # but also useful for list enumeration
    class TableList < Component
      # Creates default items if none exist
      def initialize(*args)
        super

        if !options.key?(:items)
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

        dta.font_size = if options[:font_size].nil?
                            Array.new(items.count, 14)
                          elsif options[:font_size].is_a?(Integer)
                            [
                              Array.new(items.count, options[:border_size])
                              Array.new(4 - items.count, 14)
                            ].reduce(:+)
                          elsif options[:font_size].is_a?(Array)
                            options[:font_size]
                          end

        dta.to_h
      end
    end
  end
end