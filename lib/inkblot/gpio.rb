require 'pathname'

module Inkblot
  # Handles reading pin data from the board for button input
  module GPIO
    class << self
      # Uses the raspi-gpio tool to get pin state for one or more pins +pin+
      def gpio_state(*pin)
        cmd = `raspi-gpio get #{pin.join(',')}`
        pt = /GPIO (?<pin>\d*): level=(?<level>\w*) fsel=(?<fsel>\w*)(?: alt=(?<alt>\d))? func=(?<func>\w*)(?: pull=(?<pull>\w*))?/

        st = cmd.lines
                .map { |x| x.match(pt) }
                .map(&:named_captures)
                .map { |x| x.transform_keys(&:to_sym) }
                .map { |x| map_pin(x) }

        st.one? ? st.first : st
      end

      private

      # Maps the state from +pin_st+ to useful values
      def map_pin(pin_st)
        %i[pin level fsel].each { |d| pin_st[d] = pin_st[d].to_i }

        pin_st[:direction] = case pin_st.delete(:func)
                             when 'INPUT'
                               :in
                             when 'OUTPUT'
                               :out
                             end

        pin_st[:pull] = case pin_st[:pull]
                        when 'UP'
                          :up
                        when 'DOWN'
                          :down
                        when nil
                          :unknown
                        end

        pin_st
      end
    end

    # Individual pins are controlled by instances of this class
    class Pin
      # Which pin is in question
      attr_reader :id
      # Whether we have exported the value of this pin to a synthetic file
      attr_reader :exported
      # Whether this pin is for input or output
      attr_reader :direction
      # Whether this pin pulls up or down
      attr_reader :pull

      # Takes in an integer +pn+ for which GPIO pin we are monitoring
      def initialize(pin)
        @id = pin
        @exported = File.exist?(gpio_pin_value_path)
        st = GPIO.gpio_state(pin)
        @direction = st[:direction]
        @pull = st[:pull]
      end

      # Returns true if the pin is exported and reading low
      def on?
        return false unless @exported

        cat(gpio_pin_value_path).to_i.zero?
      end

      # Returns true if the pin is exported and reading high
      def off?
        return true unless @exported

        cat(gpio_pin_value_path).to_i == 1
      end

      # Blocks until the pin state becomes on and then calls the +blk+
      def watch(&blk)
        nil until on?
        blk.call
      end

      # Exports the pin for reading
      def open
        return self if @exported

        echo(id, gpio_base_path, 'export')

        @exported = File.exist?(gpio_pin_value_path)

        self
      end

      # Unexports the pin
      def close
        return self unless @exported

        echo(id, gpio_base_path, 'unexport')
        @exported = Dir.exist?(gpio_pin_path)

        self
      end

      # Sets the direction using the pin path direction file
      def direction=(dir)
        raise ArgumentError unless %i[in out].include?(dir)

        unless direction == dir
          echo(id, gpio_pin_path, 'direction')
          @direction = GPIO.gpio_state(id)[:direction]
        end

        self
      end

      # Sets the pull using the raspi-gpio tool
      def pull=(pul)
        raise ArgumentError unless %i[up down].include?(pul)
        
        unless pull == pul
          cmd = 'raspi-gpio set '
          cmd << id.to_s
          cmd << ' p'
          cmd << case pul
                 when :up
                   'u'
                 when :down
                   'd'
                 end

          system(cmd)
          @pull = GPIO.gpio_state(id)[:pull]
        end

        self
      end

      private

      # Joins the value file in the directory defined by gpio_pin_path
      def gpio_pin_value_path
        gpio_pin_path.join('value')
      end

      # Joins the gpio_base_path and gets the subdirectory for this pin
      def gpio_pin_path
        gpio_base_path.join("gpio#{id}")
      end

      # Hard path to the gpio sysf directory
      def gpio_base_path
        Pathname.new('/sys/class/gpio')
      end

      # Reads in the object at +pths+ using File.read
      def cat(*pths)
        path = pths.reduce(Pathname.new(''), &:+)

        File.read(path)
      end

      # Writes the +value+ to the object at +pths+, using IO.write
      def echo(value, *pths)
        path = pths.reduce(Pathname.new(''), &:+)

        IO.write(path, value)
      end
    end
  end
end
