module Inkblot
  module Components
    # Shows a table of line entries, usually to describe what the side buttons do,
    # but also useful for list enumeration
    class TableList < Component
      # Creates default items if none exist
      def initialize(*args)
        super
        options[:items] ||= Array.new(rows) { |x| "Key #{x}" }
      end

      # Sugar to get to the items
      def items
        options[:items]
      end

      # Sugar for font size options, with defaults
      def font_size
        default_opt = 14
        fs = options[:font_size]
        iz = ->(it, kl) { it.is_a?(kl) }

        if fs.nil?
          Array.new(rows, default_opt)
        elsif iz[fs, Integer]
          [
            Array.new(items.count, fs),
            Array.new(rows - items.count, default_opt)
          ].reduce(&:+)
        elsif iz[fs, Array]
          fs + Array.new(rows - fs.count, default_opt)
        end
      end

      # Sugar for text align options, with defaults
      def text_align
        default_opt = -'left'
        ta = options[:text_align]
        iz = ->(it, kl) { it.is_a?(kl) }

        if ta.nil?
          Array.new(rows, default_opt)
        elsif iz[ta, String] || iz[ta, Symbol]
          [
            Array.new(items.count, ta),
            Array.new(rows - items.count, default_opt)
          ].reduce(&:+)
        elsif iz[ta, Array]
          ta + Array.new(rows - ta.count, default_opt)
        end
      end

      # Sugar for the rows option, with default
      def rows
        options.fetch(:rows, 4)
      end

      private

      # Sets height, width, and border size, passes along text_align and font_size
      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        dta.border_size = options.fetch(:border_size, 0)
        dta.font_size = font_size
        dta.text_align = text_align
        dta.rows = rows

        dta.to_h
      end
    end
  end
end
