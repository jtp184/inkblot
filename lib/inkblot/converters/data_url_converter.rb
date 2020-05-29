require 'base64'

module Inkblot
  module Converters
    # For handling data url creation for image producing components
    class DataUrlConverter < Converter
      # Possible source formats
      FORMATS = %i[path file binary base64].freeze

      # Takes in additional +opts+ for filetype and base64
      def initialize(opts = {})
        super
        @filetype = opts.fetch(:filetype, 'png')
        @format = opts.fetch(:format, :binary)
      end

      # Converts the input using data_url_from_binary
      def convert
        data_url_from_binary
      end

      private

      # Encodes the input into a base64 data url, encoding if needed
      def data_url_from_binary
        data_url = +'' << 'data:image/' << @filetype << ';base64,'

        data_url << case @format
                    when :base64
                      input
                    when :binary
                      encode_binary(input)
                    when :path
                      encode_binary File.read(input)
                    when :file
                      encode_binary File.read(input.path)
                    end
      end

      # Takes binary string +bin+ and base64 encodes it
      def encode_binary(bin)
        Base64.encode64(bin).gsub("\n", '')
      end
    end
  end
end
