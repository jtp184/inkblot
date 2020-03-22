module Inkblot
  module Components
    # Displays an image on the screen
    class FullScreenImage < Component
      IMG_SOURCES = %i[url path file]

      # Raises an argument error if no option is provided
      # whose key is within IMG_SOURCES
      def initialize(*args)
        super
        raise ArgumentError unless options.keys.any? { |k| IMG_SOURCES.include?(k) }
      end

      # Overrides this so that Display.show recieves these converters
      # instead of trying to build the html and display.
      def to_display
        case img_src
        when :url
          HtmlConverter.new(input: options[:url])
        when :path
          ImageConverter.new(input: options[:path])
        when :file
          ImageConverter.new(input: options[:file])
        end
      end

      private

      # Determines whether we are using a url, path, or file
      def img_src
        options.keys.find { |o| IMG_SOURCES.include?(o) }
      end
    end
  end
end