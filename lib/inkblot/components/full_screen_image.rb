module Inkblot
  module Components
    # Displays an image on the screen
    class FullScreenImage < Component
      # Possible image sources
      IMG_SOURCES = %i[url path file binary].freeze

      # Raises an argument error if no option is provided
      # whose key is within IMG_SOURCES
      def initialize(*args)
        super
        unless options.keys.any? { |k| IMG_SOURCES.include?(k) }
          raise ArgumentError
        end
      end

      private

      # Computes data variables, height, width, and source
      def computed
        dta = OpenStruct.new

        get_height(dta)
        get_width(dta)

        dta.source = case img_src
                     when :url
                       options[:url]
                     when :path
                       Converters::DataUrlConverter.call(
                         input: File.absolute_path(options[:path]),
                         format: :path
                       )
                     when :file
                       Converters::DataUrlConverter.call(
                        input: File.read(options[:file]),
                        format: :file
                       )
                     when :binary
                       Converters::DataUrlConverter.call(
                        input: options[:binary],
                        format: :binary
                       )
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
