module Inkblot
	# Singleton class for the e-Paper display
	module Display
		class << self
			# Set each time display is written to, represents what is being displayed
			attr_reader :current

			# Takes in an image +img+ to display on the device.
			# Can be a File, filepath string, or a Converter subclass
			def image(img)
				if img.is_a?(File) || img.is_a?(Tempfile)
					img_pth = img.path
				elsif img.is_a?(String)
					img_pth = img
				elsif img.is_a?(Inkblot::Converter)
					img_pth = img.output.path
				end

				%x(#{pyscript("display", img_pth)})
				@current = img
			end

			# Clears screen on device
			def clear
				%x(#{pyscript("clear")})
				@current = nil
			end

			# Checks if +current+ is nil
			def empty?
				current.nil?
			end

			# Aspect ratio of the screen
			def size
				{
					width: 264,
					height: 176
				}
			end

			private

			# Create a python script string. +skript+ is the script's name
			# subsequent strings are treated as arguments
			def pyscript(skript, *args)
				cmd = "python "
				cmd << Inkblot.vendor_path("#{skript}.py")
				cmd << " " << Inkblot.vendor_path

				unless args.nil? || args.empty?
					args[0..-1].each do |arg|
						cmd << " " << arg
					end
				end

				cmd
			end
		end
	end
end