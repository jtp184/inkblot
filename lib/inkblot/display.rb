module Inkblot
  # Singleton class for the e-Paper display
  class Display
    class << self
      # Set each time display is written to, represents what is being displayed
      attr_reader :current

      # Disambiguation function to take in an +obj+ and try to display it.
      # In order of resolution:
      # * Anything that responds to +to_display+ will have that method called,
      # and the result sent back to call
      # * Any Components::Component will be passed to an HtmlConverter and displayed
      # * Any Converter will have its output displayed by path
      # * Any File or Tempfile will have its output displayed by path
      # * Any string which is an existing path on system will be displayed
      # * Any string will be passed to a Components::SimpleText component, which will be
      #   passed to call
      # * Anything else raises an ArgumentError
      #
      # After being displayed, the value of current is set to the object passed in
      def call(obj)
        if obj.respond_to?(:to_display)
          call(obj.to_display)
        elsif obj.is_a?(Components::Component)
          call(obj.convert)
        elsif obj.is_a?(Converters::Converter)
          image(obj.output.path)
        elsif obj.is_a?(File) || obj.is_a?(Tempfile)
          image(obj.path)
        elsif obj.is_a?(String) && Pathname.new(obj).exist?
          image(obj)
        elsif obj.is_a?(String)
          call(Components::SimpleText.new(text: obj))
        else
          raise ArgumentError, "Cannot display #{obj.class.name}"
        end

        @current = obj
      end

      # Show the current object again, presumably after changing it
      def redisplay
        call current
      end

      # Syntactic sugar options
      alias show call
      alias [] call
      alias again redisplay

      # Clears screen on device, and sets current to nil
      def clear
        `#{pyscript('clear')}`
        @current = nil
      end

      # Checks if +current+ is nil
      def empty?
        current.nil?
      end

      # Aspect ratio of the screen, from Inkblot.screen_size
      def size
        Inkblot.screen_size
      end

      # Returns the +size+ as CSS style attributes
      def size_css
        size.transform_values { |n| "#{n}px" }
            .to_a
            .reverse
            .map { |k, v| "#{k}: #{v};" }
            .join(' ')
      end

      private

      # Takes in an image +img+ to display on the device.
      # Can be a File, filepath string, or a Converter subclass.
      # Automatically switches display script based on color depth 
      def image(img)
        disp_script = case Inkblot.color_depth
                      when 1
                        'display'
                      when 4
                        'display_4gray'
                      end

        `#{pyscript(disp_script, img)}`
      end

      # Create a python script string. +skript+ is the script's name
      # subsequent strings are treated as arguments
      def pyscript(skript, *args)
        cmd = 'python '
        cmd << Inkblot.vendor_path("#{skript}.py")
        cmd << ' ' << Inkblot.vendor_path

        unless args.nil? || args.empty?
          args[0..-1].each do |arg|
            cmd << ' ' << arg
          end
        end

        cmd
      end
    end
  end
end
