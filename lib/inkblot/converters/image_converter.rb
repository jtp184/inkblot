require 'tempfile'
require 'mini_magick'

module Inkblot
  # Converts images from other formats into grayscale bmps
  module Converters
    class ImageConverter < Converter
      # Reads input, and uses MiniMagick to modify. Modifies Tempfiles in place,
      # creates tempfiles for strings or regular files
      def convert
        if input.is_a?(File)
          img_file = Tempfile.open('inkblot-convertimage') do |f|
            f << File.read(input.path)
          end
        elsif input.is_a?(Tempfile)
          img_file = input
        elsif input.is_a?(String)
          img_file = Tempfile.open('inkblot-convertimage') do |f|
            begin
              fc = if Pathname.new(input).exist?
                File.read(input)
              else
                input
              end
            rescue ArgumentError
              fc = input
            end

            f << fc
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
          m << ("bmp3:" << img.path)
        end
      end

      # Resizes and extents image
      def resize(img)
        convert = MiniMagick::Tool::Convert.new do |m|
          m << img.path
          m.gravity('center')
          m.resize(Display.size.values.join('x'))
          m.extent(Display.size.values.join('x'))
          m << ("bmp3:" << img.path)
        end
      end
    end
  end
end