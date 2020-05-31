# frozen_string_literal: true

require 'inkblot'
require 'net/http'
require 'json'
require 'pry'

# You'll need an IEXCloud API key: https://iexcloud.io/cloud-login#/register
# You can run this example with `IEX_CLOUD_API_KEY="aa_0123456789abcdeffedcba9876543210" ruby bin/exmp/stock_ticker.rb`

# Can fetch stock quotes from IEXCloud and display them to the EPD
class StockTicker
  include Inkblot::Components::Helpers::Paginated
  include Inkblot::Components::Helpers::MultiState

  # The Base URL for the IEX api
  API_URL = 'https://sandbox.iexapis.com/stable/stock/market/batch'

  # The stock symbols to search for
  attr_reader :symbols

  # Defines states
  def_states :symbol, :overview

  # Set the instance variables to the +opts+, get API key from ENV if present
  def initialize(opts = {})
    opts.each_pair { |k, v| instance_variable_set(:"@#{k}", v) }
    @api_key ||= ENV['IEX_CLOUD_API_KEY']
    paginate(symbols.count)
  end

  # Generates a table for the report designated by the current page
  def to_display
  	case current_state
  	when :symbol
	    table_for(latest_report.values[current_page])
	  when :overview
	  	stock_overview
	  end
  end

  # Defines the button actions for the reporter
  # - 1: Next Stock
  # - 2: Previous Stock
  # - 3: Overview (TODO)
  # - 4: Abort display
  def button_actions
    return @button_actions if @button_actions

    @button_actions = []

    @button_actions << proc { next_page }
    @button_actions << proc { prev_page }

    @button_actions << proc {}

    @button_actions << proc do
    	raise IndexError, 'Cancel button was pressed'
    end
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

  # Generate a TableList for a given report
  def table_for(rpt)
    Inkblot::Components::TableList.new do |tl|
      tl.fullscreen = true
      tl.font_size = [30, 18, 12, 18]
      tl.text_align = :center
      tl.items = []

      tl.items << rpt[:symbol]
      tl.items << "$#{rpt[:latest_price]}"

      pt = %i[open high low].map { |pr| "$#{rpt[pr]}" }
                            .join("  /  ")

      tl.items << pt
      tl.items << "#{(rpt[:change_percent] * 100).round(3)}%"
    end
  end

  def stock_overview; end

  # Fetches and manipulates API data into report format
  def fetch_api_data
    addr = URI(API_URL)
    addr.query = URI.encode_www_form(form_params.transform_keys(&:to_s))

    @latest_report = JSON.parse(Net::HTTP.get(addr))
                         .transform_values! { |qt| qt['quote'] }
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
      'symbol' => :symbol,
      'latestPrice' => :latest_price,
      'change' => :change,
      'changePercent' => :change_percent,
      'open' => :open,
      'high' => :high,
      'low' => :low
    }
  end
end


#=== For Displaying on the EPD ===##
Inkblot::Buttons.init unless Inkblot::Buttons.ready?
@t = StockTicker.new(symbols: ['AAPL', 'FB'])
# binding.pry

refresh_time = 30

begin
  loop do
    Inkblot::Display.show(@t)
    Inkblot::Buttons.get_press(refresh_time)

    @t.refresh

    puts
    puts Time.now, @t.latest_report
  end
rescue IndexError
  Inkblot::Display.clear
  Inkblot::Buttons.release
  exit
end
