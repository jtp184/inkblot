require_relative 'helpers/multi_state'
require_relative 'helpers/paginated'

module Inkblot
  module Components
    # Allows displaying a variable length list of options
    class ScrollMenu < Component
      include Helpers::MultiState
      include Helpers::Paginated

      # The selected choice
      attr_reader :answer

      # Defines the possible states
      def_states :scroll, :select, :answered, :canceled

      # Defines the method to page by
      paginate_with :pad_list

      # Start codon for list
      LIST_START = '/--'.freeze
      # Stop codon for list
      LIST_END = '--/'.freeze

      # Sets the instance vars, validates the items list, and paginates
      def initialize(*args)
        super

        raise ArgumentError, 'No items given' unless options[:items]

        paginate
      end

      # Overrides what is displayed to be the content for the current page
      def to_display
        content_for_state[current_page]
      end

      # Defines actions for the Buttons depending on state
      def button_actions
        case state
        when :scroll
          [
            -> { self.state = :select },
            -> { self.state = :canceled },
            -> { self.prev_page },
            -> { self.next_page }
          ]
        when :select
          Array.new(4) do |i|
            lambda do
              ch = choice(i)
              return unless ch

              @answer = ch
              self.state = :answered
            end
          end
        else
          []
        end
      end

      # Sugar for the items array
      def items
        options[:items]
      end

      # Gets the items that the current page is presenting as choices
      def choices
        to_display.options[:choices].map { |c| c.nil? ? nil : items[c] }
      end

      # Get the choices for the current page, and return the one at index +ix+
      def choice(ix)
        items[to_display.options[:choices][ix]]
      end

      # True if the state is answered or canceled
      def concluded?
        state == :answered || state == :canceled
      end

      private

      # Sets up pagination by creating a new array that includes the list
      # start & end, and slicing it into fours. Creates content for relevant
      # states with different icons.
      def pad_list
        pg = [LIST_START]

        pg += items

        pg << LIST_END

        dx = items.each_with_index.to_h

        content_for_state(:scroll) do
          pg.each_slice(4).map do |page|
            IconPane.new do |pane|
              pane.icons = :select
              pane.div_height = pane.div_width = :full
              pane.choices = page.map { |g| dx[g] }
              pane.frame_contents = TableList.new do |lst|
                lst.items = page.map(&:to_s)
              end
            end
          end
        end

        content_for_state(:select) do
          pg.each_slice(4).map do |page|
            IconPane.new do |pane|
              pane.div_height = pane.div_width = :full
              pane.choices = page.map { |g| dx[g] }
              pane.icons = pane.choices.map { |ch| ch.nil? ? :times : :rarr }
              pane.frame_contents = TableList.new do |lst|
                lst.items = page.map(&:to_s)
              end
            end
          end
        end

        pg.each_slice(4).count
      end
    end
  end
end
