module Inkblot
  module Components
    # Allows displaying a variable length list of options
    class ScrollMenu < Component
      # What method to prepend to the iterator. Defaults to each
      attr_reader :enum_method
      # The page to display when called
      attr_accessor :current_page
      # Display scroll icons or select icons
      attr_accessor :mode

      # Start codon for list
      LIST_START = "/--".freeze
      # Stop codon for list
      LIST_END = "--/".freeze

      # Sets the instance vars, validates the items list, and paginates
      def initialize(*args)
        super  

        @enum_method ||= :each
        @current_page ||= 0
        @mode ||= :scroll

        unless options[:items] && options[:items].respond_to?(enum_method)
          raise ArgumentError, "Invalid list of items"
        end

        paginate unless options[:items]&.empty?
      end

      # Returns the page instead of having this object be displayed directly
      def to_display
        case mode
        when :scroll
          scroll_page
        when :select
          select_page
        end
      end

      # Sugar for the items array
      def items
        options[:items]
      end

      # Sets scroll mode
      def scroll
        @mode = :scroll
        self
      end

      # Sets select mode
      def select
        @mode = :select
        self
      end

      # The array of scroll pages
      def scroll_pages
        @scroll_pages ||= []
      end

      # The current scroll page
      def scroll_page
        @scroll_pages[@current_page]
      end

      # The array of select pages
      def select_pages
        @select_pages ||= []
      end

      # The current select page
      def select_page
        @select_pages[@current_page]
      end

      # Decrements the current page unless we are on the first page,
      # then returns self
      def prev_page
        return @current_page if @current_page.zero?
        @current_page -= 1
        self
      end

      # Increments the current page unless we are on the last page,
      # then returns self
      def next_page
        return @current_page if @current_page == (@scroll_pages.count - 1)
        @current_page += 1
        self
      end

      private

      # Takes the list items array, makes a new array outfixed by
      # the start / end codons, slices it into fours, and creates
      # scroll and select pages out of IconMenu instances
      def paginate
        pg = [LIST_START]
        
        items.send(enum_method).each do |i|
          pg << i.to_s
        end

        pg << LIST_END

        icm_tmp = proc do |icn, page|
          IconMenu.new do |menu|
            menu.div_height = menu.div_width = :full
            menu.icons = icn
            menu.frame_contents = ButtonMenu.new do |btn|
              btn.buttons = page
            end
          end
        end

        @scroll_pages = pg.each_slice(4).map do |page|
          icm_tmp[:select, page]
        end

        @select_pages = pg.each_slice(4).map do |page|
          icm_tmp[:arrows_in, page]
        end
      end
    end
  end
end