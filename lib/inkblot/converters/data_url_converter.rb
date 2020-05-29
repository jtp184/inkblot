require 'base64'

module Inkblot
  module Converters
    # For handling data url creation for image producing components
    class DataUrlConverter < Converter
      # Possible source formats
      FORMATS = %i[path file binary base64].freeze
      # Matches base64 strings for guessing
      BASE64_MATCHER = %r'[^-A-Za-z0-9+/=]|=[^=]|={3,}$'.freeze

      # Takes in additional +opts+ for filetype and base64
      def initialize(opts = {})
        super
        @format = opts.fetch(:format, infer_format)
        @filetype = opts.fetch(:filetype, infer_filetype)
      end

      # Converts the input using data_url_from_binary
      def convert
        data_url_from_binary
      end

      private

      # Guess the input format
      def infer_format
        izza = ->(ip) { input.is_a?(ip) }

        if izza[File] || izza[Tempfile]
          :file
        elsif izza[String] && input.ascii_only? && Pathname.new(input).exist?
          :path
        elsif izza[String] && input.match?(BASE64_MATCHER)
          :base64
        else
          :binary
        end
      end

      # Infers filetype based on format
      def infer_filetype
        case @format
        when :file
          File.extname(input.path).gsub(/^\./, '')
        when :path
          File.extname(input).gsub(/^\./, '')
        when :base64
          input.match(%r{data:image/(\w+);base64})[1]
        else
          'png'
        end
      end

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