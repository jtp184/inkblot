module Inkblot
  class Buttons
    class << self
      attr_writer :on_press

      BUTTON_PINOUT = [5, 6, 13, 19].freeze

      def pins
        @pins ||= BUTTON_PINOUT.map { |pn| GPIO::Pin.new(pn) }
      end

      def ready?
        pins.all?(&:exported)
      end

      def respond
        wait_for_press do |ky|
          on_press[ky].call
        end
      end

      def get_input
        wait_for_press
      end

      private

      def wait_for_press
        loop do
          pn = pins.find(&:on?)
          next unless pn

          pindx = BUTTON_PINOUT.index(pn.id) 
          yield pindx if block_given?
          return pindx
        end
      end

      def on_press
        @on_press ||= [
          ->{ throw :keypress_0 },
          ->{ throw :keypress_1 },
          ->{ throw :keypress_2 },
          ->{ throw :keypress_3 }
        ]
      end
    end
  end
end