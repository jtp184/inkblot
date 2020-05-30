# frozen_string_literal: true

require 'inkblot'
require 'net/http'
require 'json'
require 'pry'

# You'll need an IEXCloud API key: https://iexcloud.io/cloud-login#/register
# You can run this example with `IEX_CLOUD_API_KEY="aa_0123456789abcdeffedcba9876543210" ruby bin/exmp/stock_ticker.rb`

# Can fetch stock quotes from IEXCloud and display them to the EPD
class StockTicker
	# The Base URL for the IEX api
	API_URL = 'https://sandbox.iexapis.com/stable/stock/market/batch'

	# The stock symbols to search for
	attr_reader :symbols

	# Set the instance variables to the +opts+, get API key from ENV if present
	def initialize(opts = {})
		opts.each_pair { |k, v| instance_variable_set(:"@#{k}", v) }
		@api_key ||= ENV['IEX_CLOUD_API_KEY']
	end

	def to_display
	end

	def button_actions
	end

	# Fetch api data and return self
	def refresh
		fetch_api_data
		self
	end

	# Returns the latest report, fetching if none exists
	def latest_report
		@latest_report || fetch_api_data
	end

	private

	# Fetches and manipulates API data into report format
	def fetch_api_data
		addr = URI(API_URL)
		addr.query = URI.encode_www_form(form_params.transform_keys(&:to_s))

		@latest_report = JSON.parse(Net::HTTP.get(addr))
										     .transform_values! { |qt| qt['quote']}
									       .transform_values! { |qt| qt.slice(*quote_fields.keys) }
										     .transform_values! { |v| v.transform_keys { |j| quote_fields[j] } }
	end

	# The query params for the API request
	def form_params
		{ 
			symbols: @symbols.map(&:to_s).join(','),
			types: 'quote',
			token: @api_key
		}
	end

	# The fields on the quote responses to include in the report, and how to
	# transform them later
	def quote_fields
		{
			'latestPrice' => :price,
			'change' => :change
		}
	end
end

@s = StockTicker.new(symbols: ['AAPL', 'FB'])

binding.pry

##=== For Displaying on the EPD ===##
# Inkblot::Buttons.init unless Inkblot::Buttons.ready?
# @t = 

# refresh_time = 60

# begin
#   loop do
#     Inkblot::Display.show(@t)
#     Inkblot::Buttons.get_press(refresh_time)

#     @t.refresh

#     puts
#     puts Time.now, @t.latest_report
#   end
# rescue IndexError
#   Inkblot::Display.clear
#   Inkblot::Buttons.release
#   exit
# end
