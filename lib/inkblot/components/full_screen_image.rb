require_relative 'helpers/data_url'

module Inkblot
  module Components
    # Displays an image on the screen
    class FullScreenImage < Component
      include Helpers::DataUrl

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

      # Returns the extension type of the image
      def filetype
        case img_src
        when :url
          options[:url].split('.').last
        when :path, :file
          File.extname(options[img_src]).gsub(/[^a-z]/i, '')
        when :binary
          options[:filetype] || 'png'
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
                       File.absolute_path(options[:path])
                     when :file
                       data_url_from_binary(File.read(options[:file]), filetype)
                     when :binary
                       data_url_from_binary(options[:binary], filetype)
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
