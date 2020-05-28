require 'tempfile'
require 'mini_magick'

module Inkblot
  module Converters
    # Converts images from other formats into grayscale bmps
    class ImageConverter < Converter
      # Reads input, and uses MiniMagick to modify. Modifies Tempfiles in place,
      # creates tempfiles for strings or regular files
      def convert
        izza = ->(ft) { input.is_a?(ft) }

        img_file = if izza[File]
          Tempfile.open('inkblot-convertimage') do |f|
            f << File.read(input.path)
          end
        elsif izza[Tempfile]
          input
        elsif izza[String] && input.ascii_only? && Pathname.new(input).exist?
          Tempfile.open('inkblot-convertimage') do |f|
            f << File.read(input)
          end
        elsif izza[String]
          Tempfile.open('inkblot-convertimage') do |f|
            f << input
          end
        end

        resize(img_file)
        mono2(img_file)
        img_file
      end

      private

      # 2Channel monochrome conversion of image
      def mono2(img)
        MiniMagick::Tool::Convert.new do |m|
          m << img.path
          m.depth(1)
          m.monochrome
          m << ('bmp3:' << img.path)
        end
      end

      # Resizes and extents image
      def resize(img)
        MiniMagick::Tool::Convert.new do |m|
          m << img.path
          m.gravity('center')
          m.resize(Display.size.values.join('x'))
          m.extent(Display.size.values.join('x'))
          m << ('bmp3:' << img.path)
        end
      end
    end
  end
end
