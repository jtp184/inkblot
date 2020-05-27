require_relative 'helpers/icons'

module Inkblot
  module Components
    # Displays a grid of content, either icons or other components
    class IconGrid < Component
      include Helpers::Icons

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

        dta.icon_size = options.fetch(:icon_size, 40)

        dta.columns = options.fetch(:columns, 4)
        
        dta.font = options.fetch(:font, "'Material Icons', monospace")

        dta.border_size = if options[:border_size].nil?
                            Array.new(options[:icons].count, 0)
                          elsif options[:border_size].is_a?(Integer)
                            Array.new(options[:icons].count, options[:border_size])
                          elsif options[:border_size].is_a?(Array)
                            options[:border_size]
                          end

        dta.grid_items = []

        dta.icons = replace_icon_groups

        dta.icons.each do |icn|
          dta.grid_items << snippet_from_icn(icn)
        end

        dta.to_h
      end

      # Converts an object +icn+ into an icon representation
      def snippet_from_icn(icn)
        icn_siz = options.fetch(:icon_size, 40)

        if icn.is_a?(Components::FullScreenImage)
          fs = icn.dup
          fs.options[:div_height] = "#{icn_siz}px"
          fs.options[:div_width] = "initial"

          fs.to_html_frag
        elsif icn.is_a?(Component)
          icn.to_html_frag
        elsif icn.is_a?(String) && Pathname.new(icn).exist?
          fs = FullScreenImage.new(
            path: icn, 
            div_height: "#{icn_siz}px",
            div_width: "initial"
          )

          fs.to_html_frag
        else
          sized_span(icn.to_s)
        end
      end

      # Returns a span tag with the font sizing applied
      def sized_span(content)
        scaled = (icn_siz * 0.8).round
        %(<span style="font-size: #{scaled}px">#{content}</span>)
      end
    end
  end
end
