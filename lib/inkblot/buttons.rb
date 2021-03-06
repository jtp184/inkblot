module Inkblot
  # Singleton class that allows access to the buttons on the hat
  class Buttons
    class << self
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
          pins.all? { |n| n.pull != :down }
      end

      # Passes the +timeout+ to get_input, and calls the associated proc on
      # the object that is Display.current, with some guard clauses
      def get_press(timeout = nil)
        unless Display.current.respond_to?(:button_actions)
          raise NoMethodError, "#{Display.current.class.name} has no #button_actions"
        end

        ky = get_input(timeout)

        return nil if ky.nil?

        Display.current.button_actions[ky].call
      end

      # Gets input from the buttons. Blocks until a pin reads as on
      # or the timeout elapses. If timeout is nil, will block forever
      # until it recieves a press, and then return the index of the button.
      # If not nil, will return the index or nil if no button was pressed.
      def get_input(timeout = nil)
        ts = Time.now

        loop do
          if timeout
            return nil if Time.now - ts > timeout
          end

          pn = pins.find(&:on?)
          next unless pn

          pindx = Inkblot.button_pinout.index(pn.id)

          return pindx
        end
      end

      # Takes in a +btn_ct+ integer for how many simultaneous buttons to watch for,
      # and passes +timeout+, returns an array
      def get_multi_input(btn_ct = 2, timeout = nil)
        ts = Time.now

        loop do
          if timeout
            return nil if Time.now - ts > timeout
          end

          pn = pins.find_all(&:on?)
          next if pn.empty?
          next unless pn.count == btn_ct

          pindx = pn.map { |n| Inkblot.button_pinout.index(n.id) }

          return pindx
        end
      end

      # Loops for +timefr+ seconds collecting the status of the pins.
      # Yields that status to a block if given, and returns the collection
      def get_raw_input(timefr = 1)
        ts = Time.now

        inputs = []

        loop do
          break if Time.now - ts > timefr

          cur = Array(pins.find_all(&:on?).map { |pn| Inkblot.button_pinout.index(pn.id) })

          yield cur if block_given?
          inputs << cur
        end

        inputs
      end
    end
  end
end
