module Inkblot
	# Handles reading pin data from the board for button input
	module GPIO
		class Pin
			# Which pin is in question
			attr_accessor :id

			def initialize(opts={})
				@id = opts.fetch(:id)
			end

			def on?
				# Probably read this from /dev or /sys
			end

			def off?
				# Probably read this from /dev or /sys
			end

			def watch(&blk)
				nil until on?
				blk.call
			end

			private
		end
	end
end