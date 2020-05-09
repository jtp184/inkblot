require 'base64'

module Inkblot
  module Components
    # Displays an image on the screen
    class FullScreenImage < Component
      # Possible image sources
      IMG_SOURCES = %i[url path file].freeze

      # Raises an argument error if no option is provided
      # whose key is within IMG_SOURCES
      def initialize(*args)
        super
        unless options.keys.any? { |k| IMG_SOURCES.include?(k) }
          raise ArgumentError
        end
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

      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        dta.source = case img_src
                     when :url
                       options[:url]
                     when :path
                       File.absolute_path(options[:path])
                     when :file
                       bs = +"" << 'data:image/'
                       bs << File.extname(options[:file]).gsub(/[^a-z]/i, '')
                       bs << ';base64,'

                       binary = File.read(options[:file].path)
                       bs << Base64.encode64(binary).gsub("\n", '')
                       bs
                     end

        dta.to_h
      end

      # Determines whether we are using a url, path, or file
      def img_src
        options.keys.find { |o| IMG_SOURCES.include?(o) }
      end
    end
  end
end
