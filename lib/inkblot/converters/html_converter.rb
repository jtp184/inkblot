require 'base64'
require 'tty-command'

module Inkblot
  module Converters
    # Converts HTML input into an image by passing it into an ImageConverter
    class HtmlConverter < Converter
      # Uses image_contents to create a page from passed input.
      # Returns a (closed) tempfile created from an ImageConverter
      def convert
        ImageConverter.new(input: image_contents).convert
      end

      # Returns a DataUrl representation
      def data_url
        DataUrlConverter.new(input: puppeteer, format: :base64)
      end

      # Returns png data from puppeteer instance called on input
      def image_contents
        Base64.decode64(puppeteer)
      end

      # Saves the converted image permanently to path. Converts if this has not been done
      def save(path)
        convert!

        File.open(path, 'w+b') do |f|
          f << File.read(output.path)
        end
      end

      # The TTY::Command instance to puppeteer through
      def self.shell
        @shell ||= TTY::Command.new(printer: :null)
      end

      private

      # Constructs the command and passes the input to the vendor/puppeteer.js
      # script for processing. Returns a base64 encoded string
      def puppeteer
        cmd = +'node '
        cmd << Inkblot.vendor_path('puppeteer.js') << ' '
        cmd << Inkblot.screen_size[:width].to_s << ' '
        cmd << Inkblot.screen_size[:height].to_s << ' '

        b64, _err = self.class.shell.run(cmd, in: input)
        b64
      end
    end
  end
end
