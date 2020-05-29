require "inkblot/version"
require "inkblot/gpio"
require "inkblot/buttons"
require "inkblot/display"
require "inkblot/converters"
require "inkblot/components"

# Ruby gem for interacting with waveshare e-Paper display
module Inkblot
	class << self
		# Returns the path to the vendor directory for this gem, to access non-ruby
		# assets like python code and html templates.
		# If +paths+ are appended, joins them to the base with '/'
		def vendor_path(*paths)
			@vendor_path ||= String.new(ENV['GEM_HOME'] || Gem.default_path.last).tap do |str|
				str << "/gems"
				str << "/inkblot-#{Inkblot::VERSION}"
				str << "/vendor"
			end

			return @vendor_path if paths.empty?

			[String.new(@vendor_path)].concat(paths).join('/')
		end

		# Allows for overwriting of the screen size for different HATs
		attr_writer :screen_size
		
		# Aspect ratio of the screen
		def screen_size
			@screen_size ||= {
				width: 264,
				height: 176
			}
		end

		# Allows for overwriting of the button pinout for different HATs
		attr_writer :button_pinout

		# Which pins are assigned to which of the four buttons, from top down
		def button_pinout
			@button_pinout ||= [5, 6, 13, 19].freeze
		end
	end
end