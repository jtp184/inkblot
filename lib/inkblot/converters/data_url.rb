require 'base64'

module Inkblot
  module Converters
    # For handling data url creation for image producing components
    class DataUrl < Converter
      def initialize(opts = {})
        super
        @filetype = opts.fetch(:filetype, 'png')
      end

      def convert
        data_url_from_binary(input, @filetype)
      end

      private

      # Encodes the binary string +bs+ into a base64 data url
      def data_url_from_binary(bs, filetype)
        data_url = +'' << 'data:image/'
        data_url << filetype
        data_url << ';base64,'
        data_url << Base64.encode64(bs).gsub("\n", '')
      end
    end
  end
end
