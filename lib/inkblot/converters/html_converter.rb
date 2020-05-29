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
        DataUrl.new(input: puppeteer, base64: true)
      end

      # Returns png data from a grover instance called on input
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

      private

      # Constructs the command and passes the input to the vendor/puppeteer.js
      # script for processing. Returns a base64 encoded string
      def puppeteer
        @@cmd ||= TTY::Command.new(printer: :null)

        cmd = +'node '
        cmd << Inkblot.vendor_path('puppeteer.js') << ' '
        cmd << Inkblot.screen_size[:width].to_s << ' '
        cmd << Inkblot.screen_size[:height].to_s << ' '

        b64, _err = @@cmd.run(cmd, in: input)
        b64
      end
    end
  end
end
