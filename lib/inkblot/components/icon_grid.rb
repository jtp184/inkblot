module Inkblot
  module Components
    # Display multiple icons as the primary content
    class IconGrid < Component
      # Sets a default font_size if none exists
      def initialize(*args)
        super
        options[:icon_size] ||= 40
      end

      # Sugar method for the icons
      def icons
        options[:icons]
      end

      private

      # Sets width/height, and populates the grid_items with the icons
      def computed
        dta = OpenStruct.new
        
        get_height(dta)
        get_width(dta)

        dta.columns = options.fetch(:columns, 4)

        dta.grid_items = []

        options[:icons].each do |icn|
          dta.grid_items << snippet_from_icn(icn)
        end

        dta.to_h
      end

      # Converts an object +icn+ into an icon representation
      def snippet_from_icn(icn)
        if icn.is_a?(Components::FullScreenImage)
          fs = icn.dup
          fs.options[:div_height] = "#{options[:icon_size]}px"
          fs.options[:div_width] = "initial"

          fs.to_html_frag
        elsif icn.is_a?(Component)
          icn.to_html_frag
        elsif icn.is_a?(Symbol)
          %(<span style="font-size: #{(options[:icon_size] * 0.8).round}px">&#{icn.to_s};</span>)
        elsif icn.is_a?(String) && Pathname.new(icn).exist?
          fs = FullScreenImage.new(
            path: icn, 
            div_height: "#{options[:icon_size]}px",
            div_width: "initial"
          )

          snippet_from_icn(fs)
        else
          %(<span style="font-size: #{(options[:icon_size] * 0.8).round}px">#{icn.to_s}</span>)
        end
      end
    end
  end
end
