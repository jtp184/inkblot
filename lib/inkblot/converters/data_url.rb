require 'base64'

module Inkblot
  module Converters
    # For handling data url creation for image producing components
    class DataUrl < Converter
      # Takes in additional +opts+ for filetype and base64
      def initialize(opts = {})
        super
        @filetype = opts.fetch(:filetype, 'png')
        @base64 = opts.fetch(:base64, false)
      end

      # Converts the input using data_url_from_binary
      def convert
        data_url_from_binary
      end

      private

      # Encodes the input into a base64 data url, encoding if needed
      def data_url_from_binary
        data_url = +'' << 'data:image/'
        data_url << @filetype
        data_url << ';base64,'
        data_url << if @base64
                      input
                    else
                      Base64.encode64(input).gsub("\n", '')
                    end
      end
    end
  end
end
