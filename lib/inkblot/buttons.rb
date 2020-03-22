module Inkblot
  # Singleton class that allows access to the buttons on the hat
  class Buttons
    class << self
      # Array of procs that can be used to define button callbacks
      attr_writer :on_press

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
        @pins ||= Inkblot.button_pinout.map { |pn| GPIO::Pin.new(pn) }
      end

      # Sets the pull and direction for each pin, and exports them
      def init
        pins.each do |pn|
          pn.pull = :up
          pn.direction = :in
          pn.open
        end
      end

      # Unexports the pins
      def release
        pins.map(&:close)
      end

      # True if all the pins are exported, set as input, and pulled up
      def ready?
        pins.all?(&:exported) && 
        pins.all? { |n| n.direction == :in } &&
        pins.all? { |n| n.pull == :up }
      end

      # Uses the on_press procs to respond to input, passing +timeout+
      def get_press(timeout=nil)
        ky = get_input(timeout)
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

          pindx = Inkblot.button_pinout.index(pn.id) 

          return pindx
        end
      end
    end
  end
end