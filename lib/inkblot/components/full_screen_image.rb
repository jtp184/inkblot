require 'base64'

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
                       encode_binary(File.read(options[:file]))
                     when :binary
                       encode_binary(options[:binary])
                     end

        dta.to_h
      end

      # Encodes the binary string +bs+ into a base64 data url
      def encode_binary(bs)
        data_url = +"" << 'data:image/'
        data_url << filetype
        data_url << ';base64,'
        data_url << Base64.encode64(bs).gsub("\n", '')
      end

      # Determines whether we are using a url, path, or file
      def img_src
        options.keys.find { |o| IMG_SOURCES.include?(o) }
      end
    end
  end
end
