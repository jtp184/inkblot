require 'grover'

module Inkblot
  module Converters
    # Converts HTML input into an image by passing it into an ImageConverter
    class HtmlConverter < Converter
      # Uses image_contents to create a page from passed input.
      # Returns a (closed) tempfile created from an ImageConverter
      def convert
        ImageConverter.new(input: image_contents).convert
      end

      def data_url
        DataUrl.new(input: image_contents)
      end

      # Returns png data from a grover instance called on input
      def image_contents
        Grover.new(input, viewport: Display.size).to_png
      end

      # Saves the converted image permanently to path. Converts if this has not been done
      def save(path)
        convert!

        File.open(path, 'w+b') do |f|
          f << File.read(output.path)
        end
      end
    end
  end
end
