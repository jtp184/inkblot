module Inkblot
  module Components
    # Shows text on the screen
    class SimpleText < Component
      # Sugar method for accessing the text data
      def text
        options[:text]
      end
      
      private

      # Derives the tag to wrap text in from the size option,
      # and sets the needed values not already set
      def computed
        dta = OpenStruct.new
        optionals(dta)
        get_height(dta)
        get_width(dta)
        dta.tag = tag_from_size
        dta.font_size = size_value
        dta.to_h
      end

      # Takes in the +dta+ struct and sets optional values to their
      # defaults if needed
      def optionals(dta)
        dta[:border_size] = options.fetch(:border_size, 0)
        dta[:font] = options.fetch(:font, "monospace")
        dta[:size] = options.fetch(:size, :large)
        dta[:text_align] = options.fetch(:text_align, "center")
      end

      # Set an html tag based on the provided size
      def tag_from_size
        case options[:size]
        when :tiny
          'p'
        when :small
          'h3'
        when :medium
          'h2'
        when :large
          'h1'
        when nil 
          auto_scale_tag
        when ->(x) { x.is_a?(Integer) }
          'h1'
        end
      end

      # Returns a numeric value from the size option if possible
      def size_value
        return nil if options[:size].is_a?(Symbol)
        return "#{options[:size]}px" if options[:size].is_a?(Integer)
        return options[:size]
      end

      # Return a tag based on text length
      def auto_scale_tag
        case options[:text].length
        when 0..70
          'h1'
        when 70..200
          'h3'
        else
          'p'
        end
      end
    end
  end
end