require 'imgkit'
require 'tempfile'
require 'securerandom'
require 'mini_magick'

module Inkblot
	# Abstract class for converting content from one form to another
	class Converter
		# The passed object to convert
		attr_accessor :input
		# The bmp file to display on the device
		attr_reader :output

		# Take in +input+ and any other args
		def initialize(opts={})
			@input = opts.fetch(:input)
		end

		# Implemented on the superclass for consistency
		def convert!
			@output = convert
			self
		end

		# Child classes override to implement core behavior
		def convert
			@input
		end

		# Override so that we can't call this without conversion
		def output
			return @output if @output
			convert!
			@output
		end
	end

	# Converts images from other formats into grayscale bmps
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

	# Converts HTML input into an image by passing it into an ImageConverter
	class HtmlConverter < Converter
		# Uses IMGKit to create a page from passed input. 
		# Returns a (closed) tempfile created from an ImageConverter
		def convert
			img = IMGKit.new(input, Display.size)
			ImageConverter.new(input: img.to_png).convert
		end

		# Reads the tempfile and returns the contents. Converts if this has not been done
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