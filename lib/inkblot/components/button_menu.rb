module Inkblot
  module Components
    # Shows a table of line entries, usually to describe what the side buttons do,
    # but could also be useful for list enumeration
    class ButtonMenu < Component
      # Creates default buttons if none exist
      def initialize(*args)
        super

        if !options.key?(:buttons)
          options[:buttons] = Array.new(4) { |x| "Key #{x}" }
        end
      end

      # Sugar to get to the buttons
      def buttons
        options[:buttons]
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