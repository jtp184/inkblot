module Inkblot
  module Components
    module Helpers
      # Adds page tracking functions
      module Paginated
        # The methods to add to the class
        module ClassMethods
          # Sets the starting page to +pg+
          def start_page(pg)
            @starting_page = pg
          end

          # Defaults the starting page to 0 if unset
          def starting_page
            @starting_page ||= 0
          end

          # The method to set up pagination with. Must return the page count.
          def paginate_with(mtd)
            @paginate_with_method = mtd
          end

          # Attribute accessor for the pagination method
          def paginate_with_method
            @paginate_with_method
          end
        end

        # Extends the +base+ class with the ClassMethods
        def self.included(base)
          base.extend(Paginated::ClassMethods)
        end

        # Retrieves the current page, defualts to the starting page if not
        # already set
        def current_page
          @current_page ||= self.class.starting_page
        end

        # Directly sets the current page to the +nu_page+
        def current_page=(nu_page)
          @current_page = nu_page
        end

        # Invokes the pagination method, sets the page count with its result
        def paginate(over=nil)
          @page_count ||= over || send(self.class.paginate_with_method)
        end

        # The number of pages, set after paginate has run
        def page_count
          @page_count
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
end