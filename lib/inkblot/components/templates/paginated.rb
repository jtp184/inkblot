module Inkblot
  module Templates
    module Paginated
      module ClassMethods
        def start_page(pg)
          @starting_page = pg
        end

        def starting_page
          @starting_page ||= 0
        end
      end

      def self.included(base)
        base.extend(Paginated::ClassMethods)
      end

      def current_page
        @current_page ||= self.class.starting_page
      end

      # Decrements the current page unless we are on the first page,
      # then returns self
      def prev_page
        return current_page if current_page.zero?
        @current_page -= 1
        self
      end

      # Increments the current page unless we are on the last page,
      # then returns self
      def next_page
        return current_page if current_page == (@page_count - 1)
        @current_page += 1
        self
      end
    end
  end
end