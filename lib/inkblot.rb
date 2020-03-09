require "inkblot/version"
require "inkblot/gpio"
require "inkblot/buttons"
require "inkblot/display"
require "inkblot/converter"

# Ruby gem for interacting with waveshare e-Paper display
module Inkblot
	class << self
		# Returns the path to the vendor directory for this gem, to access non-ruby
		# assets like python code and html templates.
		# If +paths+ are appended, joins them to the base with '/'
		def vendor_path(*paths)
			@vendor_path ||= String.new(ENV['GEM_HOME']).tap do |str|
				str << "/gems"
				str << "/inkblot-#{Inkblot::VERSION}"
				str << "/vendor"
			end

			return @vendor_path if paths.empty?

			[String.new(@vendor_path)].concat(paths).join('/')
		end
	end
end