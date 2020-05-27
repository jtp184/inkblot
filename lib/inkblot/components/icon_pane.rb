require_relative 'helpers/material_icons'

module Inkblot
  module Components
    # Displays two panes, one on the left with icons,
    # one on the right which can be a component
    class IconPane < Component
      include Helpers::MaterialIcons

      # Predefined icon groups
      def self.icon_groups
        {
          arrows: %i[nwarr larr swarr swarr],
          arrows_out: %i[nwarr larr swarr swarr],
          arrows_in: Array.new(4) { :rarr },
          select: %i[check times uarr darr],
          confirm: %i[check times],
          agree: [:check],
          cancel: [:times]
        }
      end

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
        
        unless fr.is_a?(Array)
          fr = Array(fr)
        end

        dta.frame = fr.map(&:to_html_frag).join("\n")
        
        dta.to_h
      end

      # The default icons, html symbols for bubble numbers 1-4
      def default_icons
        (10112..10115).to_a.map { |n| :"##{n}" }
      end

      # Takes in the symbol +icn+ and converts it into a material icon
      # or a basic HTML symbol if it isn't a material icon
      def html_sym(icn)
        mi = material_icon_sym(icn)
        "&#{(mi ? mi : icn).to_s};"
      end

      # Handles the work of converting user input into display logic.
      # * If no icons is given uses the default
      # * If a single symbol is given, uses the icon_groups
      # * If an array is given, runs sym args through html_sym
      # * If anything else is given it's arrayified for simplicity
      def replace_icon_groups
        ig = if options[:icons].nil?
               default_icons
             elsif options[:icons].is_a?(Symbol)
               self.class.icon_groups[options[:icons]]
             elsif options[:icons].is_a?(Array)
               options[:icons]
             else
               Array(options[:icons])
             end

        ig.map do |ic|
          ic.is_a?(Symbol) ? html_sym(ic) : ic
        end
      end
    end
  end
end