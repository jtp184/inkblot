module Inkblot
  module Components
    # Displays a grid of content, either icons or other components
    class IconGrid < Component
      include Helpers::Icons

      # Sugar method for the icons
      def icons
        options[:icons]
      end

      # Sugar method for the icon size, with default
      def icon_size
        options.fetch(:icon_size, 40)
      end

      # Sugar method for the font, with default
      def font
        options.fetch(:font, 'Material Icons, monospace')
      end

      # Sugar method for the columns count, with default
      def columns
        options.fetch(:columns, 4)
      end

      private

      # Sets width/height, and populates the grid_items with the icons
      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        dta.icons = replace_icon_groups

        dta.border_size = if options[:border_size].nil?
                            Array.new(dta.icons.count, 0)
                          elsif options[:border_size].is_a?(Integer)
                            Array.new(dta.icons.count, options[:border_size])
                          elsif options[:border_size].is_a?(Array)
                            options[:border_size]
                          end

        %i[icon_size font columns].each { |a| dta[a] = send(a) }

        dta.grid_items = []

        dta.icons.each do |icn|
          dta.grid_items << snippet_from_icn(icn)
        end

        dta.to_h
      end

      # Converts an object +icn+ into an icon representation
      def snippet_from_icn(icn)
        if icn.is_a?(Components::FullScreenImage)
          fs = icn.dup
          fs.options[:div_height] = "#{icon_size}px"
          fs.options[:div_width] = 'initial'

          fs.to_html_frag
        elsif icn.is_a?(Component)
          icn.to_html_frag
        elsif icn.is_a?(String) && Pathname.new(icn).exist?
          fs = FullScreenImage.new(
            path: icn,
            div_height: "#{icon_size}px",
            div_width: 'initial'
          )

          fs.to_html_frag
        else
          sized_span(icn.to_s)
        end
      end

      # Returns a span tag with the font sizing applied
      def sized_span(content)
        scaled = (icon_size * 0.8).round

        [
          %(<span style="font-size: #{scaled}px; font-family: #{font};">),
          %(#{content}</span>)
        ].join
      end
    end
  end
end
