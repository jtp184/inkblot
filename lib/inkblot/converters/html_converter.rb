require 'grover'

module Inkblot
  module Converters
    # Converts HTML input into an image by passing it into an ImageConverter
    class HtmlConverter < Converter
      # Uses Grover to create a page from passed input.
      # Returns a (closed) tempfile created from an ImageConverter
      def convert
        ImageConverter.new(
          input: Grover.new(input, viewport: Display.size).to_png
        ).convert
      end

      # Reads the tempfile and returns the contents. 
      # Converts if this has not been done
      def image_contents
        convert! unless output
        File.read(output.path)
      end

      # Saves the image permanently to path. Converts if this has not been done
      def save(path)
        convert! unless output
        File.open(path, 'w+b') do |f|
          f << File.read(output.path)
        end
      end
    end
  end
end
