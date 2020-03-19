require 'pathname'

module Inkblot
	# Handles reading pin data from the board for button input
	module GPIO
		class Pin
			# Which pin is in question
			attr_reader :id
			attr_reader :exported

			def initialize(pn)
				@id = pn
				@exported = File.exist?(gpio_pin_value_path)
			end

			def on?
				return false unless @exported
				cat(gpio_pin_value_path).to_i == 0
			end

			def off?
				return true unless @exported
				cat(gpio_pin_value_path).to_i == 1
			end

			def watch(&blk)
				nil until on?
				blk.call
			end

			def open
				return self if @exported
				
				echo(id, gpio_base_path, 'export')
				
				@exported = File.exist?(gpio_pin_value_path)

				self
			end

			def close
				return self unless @exported

				echo(id, gpio_base_path, 'unexport')
				@exported = Dir.exist?(gpio_pin_path)

				self
			end

			private

			def gpio_pin_value_path
				gpio_pin_path.join('value')
			end

			def gpio_pin_path
				gpio_base_path.join("gpio#{id}")
			end

			def gpio_base_path
				Pathname.new("/sys/class/gpio")
			end

			def cat(*pths)
				path = pths.reduce(Pathname.new(""), &:+)

				File.read(path)
			end

			def echo(value, *pths)
				path = pths.reduce(Pathname.new(""), &:+)

				IO.write(path, value)
			end
		end
	end
end