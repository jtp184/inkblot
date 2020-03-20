module Inkblot
  module Components
    class ButtonMenu < Component
      def initialize(*args)
        super

        if !options.key?(:buttons)
          options[:buttons] = Array.new(4) { |x| "Key #{x}" }
        end
      end

      def buttons
        options[:buttons]
      end

      private

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