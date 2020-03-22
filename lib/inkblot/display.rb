module Inkblot
	# Singleton class for the e-Paper display
	module Display
		class << self
			# Set each time display is written to, represents what is being displayed
			attr_reader :current

			# Disambiguation function to take in an +obj+ and try to display it
			def call(obj)
				if obj.respond_to?(:to_display)
					call(obj.to_display)
				elsif obj.is_a?(Components::Component)
					img = HtmlConverter.new(input: obj.to_html).convert!
					image(img.output.path)
				elsif obj.is_a?(Converter)
					image(obj.output.path)
				elsif obj.is_a?(File) || obj.is_a?(Tempfile)
					image(obj.path)
				elsif obj.is_a?(String) && Pathname.new(obj).exist?
					image(obj)
				elsif obj.is_a?(String)
					call(Components::SimpleText.new(text: obj))
				else
					raise ArgumentError, "Cannot display #{obj.class.name}"
				end
				
				@current = obj
			end

			alias show call
			alias [] call

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
				Inkblot.screen_size
			end

			# Returns the +size+ as CSS style attributes
			def size_css
				size.transform_values { |n| "#{n}px" }
            .to_a
            .reverse
            .map { |k, v| "#{k}: #{v};"}
            .join(' ')
			end

			private

			# Takes in an image +img+ to display on the device.
			# Can be a File, filepath string, or a Converter subclass
			def image(img)
				%x(#{pyscript("display", img)})
			end

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