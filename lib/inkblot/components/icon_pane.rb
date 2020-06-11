module Inkblot
  module Components
    # Displays two panes, one on the left with icons,
    # one on the right which can be a component
    class IconPane < Component
      include Helpers::Icons

      # Sugar to get to the icons options
      def icons
        options[:icons]
      end

      # Sugar to get to the frame_contents option
      def frame_contents
        options[:frame_contents]
      end

      private

      # Turns the frame contents into the frame, array-ifying and joining
      # the fragments as needed, handles icon height and replacement.
      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        dta.icons = replace_icon_groups

        dta.icon_size = case options[:icon_size]
                        when nil
                          Array.new(4, 30)
                        when ->(x) { x.is_a?(Integer) }
                          Array.new(4, options[:icon_size])
                        when ->(x) { x.is_a?(Array) }
                          options[:icon_size]
                        end

        dta.icon_height = if options[:fixed_height]
                            25
                          else
                            (100 / dta.icons.count)
                          end

        dta.font = options.fetch(:font, "'Material Icons', monospace")

        fr = options.fetch(:frame_contents, [])

        fr = Array(fr) unless fr.is_a?(Array)

        dta.frame = fr.map(&:to_html_frag).join("\n")

        dta.to_h
      end
    end
  end
end
