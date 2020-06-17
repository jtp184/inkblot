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
        write_temp = proc do |cont|
          Tempfile.open('inkblot-convertimage') do |f|
            f << cont
          end
        end

        img_file = if izza[File]
                     write_temp[File.read(input.path)]
                   elsif izza[Tempfile]
                     input
                   elsif izza[String] && input.ascii_only? && Pathname.new(input).exist?
                     write_temp[File.read(input)]
                   elsif izza[String]
                     write_temp[input]
        end

        resize(img_file)
        mono(img_file)
        img_file
      end

      # Saves the converted image permanently to path. 
      # Converts if this has not been done
      def save(path)
        File.open(path, 'w+b') do |f|
          f << File.read(output.path)
        end
      end

      private

      # Monochromatic representation of image
      def mono(img)
        MiniMagick::Tool::Convert.new do |m|
          m << img.path
          m.colorspace('Gray')
          m.depth(Inkblot.color_depth)
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
