module Inkblot
  # Allows access to the buttons on the hat
  class Buttons
    class << self
      # Array of procs that can be used to define button callbacks
      attr_writer :on_press

      # The specific pins in use by the waveshare hat
      BUTTON_PINOUT = [5, 6, 13, 19].freeze

      # Array of procs that can be used to define button callbacks. 
      # Defaults to throwing :keypress_n
      def on_press
        @on_press ||= [
          ->{ throw :keypress_0 },
          ->{ throw :keypress_1 },
          ->{ throw :keypress_2 },
          ->{ throw :keypress_3 }
        ]
      end

      # Creates new GPIO::Pin objects from the BUTTON_PINOUT
      def pins
        @pins ||= BUTTON_PINOUT.map { |pn| GPIO::Pin.new(pn) }
      end

      # True if all the pins are exported
      def ready?
        pins.all?(&:exported)
      end

      # Uses the on_press procs to respond to input, passing +timeout+
      def respond(timeout=nil)
        ky = wait_for_press(timeout)
        on_press[ky].call
      end

      # Gets input from the buttons. Blocks until a pin reads as on
      # or the timeout elapses. If timeout is nil, will block forever
      # until it recieves a press, and then return the index of the button.
      # If not nil, will return the index or nil if no button was pressed.
      def get_input(timeout=nil)
        ts = Time.now

        loop do
          if timeout
            return nil if (Time.now - ts > timeout)
          end

          pn = pins.find(&:on?)
          next unless pn

          pindx = BUTTON_PINOUT.index(pn.id) 

          return pindx
        end
      end
    end
  end
end