module Inkblot
  module Components
    # Displays two panes, one on the left with icons,
    # one on the right which can be a component
    class IconMenu < Component
      # Converts icon groups if given
      def initialize(*args)
        super
        options[:icons] = replace_icon_groups
      end

      # Sugar to get to the icons options
      def icons
        options[:icons]
      end

      private

      # Turns the frame contents into the frame, array-ifying and joining
      # the fragments as needed.
      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        fr = options.fetch(:frame_contents, [])
        Array(fr) unless fr.is_a?(Array)

        dta.frame = fr.map(&:to_html_frag).join("\n")
        
        dta.to_h
      end

      # Some default options for icons
      # * :arrows => Arrows which point offscreen to the keys
      # * :select => Shows a check, cancel, up arrow, and down arrow
      # * :confirm => 2 button, check and cancel
      # * :agree => 1 button check
      # * :cancel => 1 button cancel
      def replace_icon_groups
        case options[:icons]
        when nil
          (10112..10115).to_a.map { |n| :"##{n}" }
        when :arrows
          %i[nwarr larr swarr swarr]
        when :select
          %i[check times uarr darr]
        when :confirm
          %i[check times]
        when :agree
          [:check]
        when :cancel
          [:times]
        when ->(x) { x.is_a?(Array) }
          options[:icons]
        else
          Array(options[:icons])
        end
      end
    end
  end
end