module Inkblot
  module Components
    class IconMenu < Component
      def initialize(*args)
        super

        if !options.key?(:icons)
          options[:icons] = (10112..10115).to_a.map { |n| :"##{n}" }
        elsif options[:icons] == :arrows
          options[:icons] = %i[nwarr larr swarr swarr]
        elsif options[:icons] == :cancel
          options[:icons] = [:times]
        elsif options[:icons] == :confirm
          options[:icons] = %i[check times]
        elsif options[:icons] == :select
          options[:icons] = %i[check times uarr darr]
        end
      end

      def icons
        options[:icons]
      end

      private

      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        dta.frame = options.fetch(:frame_contents, [])
                           .map(&:to_html_frag)
                           .join("\n")
        
        dta.to_h
      end
    end
  end
end