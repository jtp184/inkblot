# frozen_string_literal: true

require 'inkblot'
require 'net/http'
require 'json'

# You'll need an IEXCloud API key: https://iexcloud.io/cloud-login#/register
# You can run this example with `IEX_CLOUD_API_KEY="aa_0123456789abcdeffedcba9876543210" ruby bin/exmp/stock_ticker.rb`

# Can fetch stock quotes from IEXCloud and display them to the EPD
class Inkblot::Examples::StockTicker
  include Inkblot::Components::Helpers::Paginated
  include Inkblot::Components::Helpers::MultiState
  include JSON

  # The Base URL for the IEX api
  API_URL = 'https://sandbox.iexapis.com/stable/stock/market/batch'

  # The stock symbols to search for
  attr_reader :symbols

  # Defines states
  def_states :current, :historical

  # Set the instance variables to the +opts+, get API key from ENV if present
  def initialize(opts = {})
    opts.each_pair { |k, v| instance_variable_set(:"@#{k}", v) }
    @api_key ||= ENV['IEX_CLOUD_API_KEY']
    paginate(symbols.count)
  end

  # Generates a table for the report designated by the current page
  def to_display
    case state
    when :current
      table_for(latest_report.values[current_page][:quote])
    when :historical
      chart_for(latest_report.values[current_page][:chart])
    end
  end

  # Defines the button actions for the reporter by returning method objects
  # - 1: Refresh
  # - 2: Next stock
  # - 3: Week of Historical data
  # - 4: Exit
  def button_actions
    @button_actions ||= %i[
      refresh_screen
      cycle_pages
      toggle_state
      exit_program
    ].map { |m| method(m) }
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

  # Refreshes and redisplays the screen. Key1 action
  def refresh_screen
    refresh
    
    Inkblot::Display.again
  end

  # Loops through pages and redisplays the screen. Key2 action
  def cycle_pages
    if current_page == (page_count - 1)
      self.current_page = 0
    else
      next_page
    end

    Inkblot::Display.again
  end

  # Changes state from :current to :historical and back. Key3 action
  def toggle_state
    if state == :current
      self.state = :historical
    elsif state == :historical
      self.state = :current
    end

    Inkblot::Display.again
  end

  # Raises an IndexError. Key4 action
  def exit_program
    raise IndexError, 'Cancel button was pressed'
  end

  private

  # Generate a TableList for a given report
  def table_for(rpt)
    Inkblot::Components::TableList.new do |tl|
      tl.div_height = :full
      tl.div_width = 95

      tl.font_size = [30, 18, 12, 18]
      tl.text_align = :center
      tl.items = []

      tl.items << rpt[:symbol]
      tl.items << "$#{rpt[:latest_price]}"

      pt = %i[open high low].map { |pr| "$#{rpt[pr]}" }
                            .join('  /  ')

      tl.items << pt
      tl.items << "#{(rpt[:change_percent] * 100).round(3)}%"
    end
  end

  # Generates an IconGrid for the given report
  def chart_for(rpt)
    Inkblot::Components::IconGrid.new do |ig|
      ig.div_height = :full
      ig.div_width = 95

      ig.icons = chart_data(rpt)

      lbl = Inkblot::Components::Component.new(
        body: %(<div><span>#{symbols[current_page]}</span></div>)
      )

      ig.icons.unshift(lbl)
    end
  end

  # Fetches and manipulates API data into report format
  def fetch_api_data
    addr = URI(API_URL)
    addr.query = URI.encode_www_form(form_params.transform_keys(&:to_s))

    @latest_report = JSON.parse(Net::HTTP.get(addr)).transform_values! do |js|
      qf = js['quote'].slice(*quote_fields.keys)
                      .transform_keys { |j| quote_fields[j] }

      cf = js['chart'].map do |cd|
        cd.slice(*chart_fields.keys).transform_keys { |j| chart_fields[j] }
      end

      { quote: qf, chart: cf }
    end
  end

  # The query params for the API request
  def form_params
    {
      symbols: @symbols.map(&:to_s).join(','),
      types: 'quote,chart',
      token: @api_key
    }
  end

  # Fields to include for the chart responses, and their transforms
  def chart_fields
    {
      'label' => :label,
      'close' => :close
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

  # Takes in the +chart+ and converts it into basic Components
  def chart_data(chart)
    temp = <<~DOC
      <div>
        <span style="font-size: 10pt;">
          <em>
            %s
          </em>
        </span>
        <br>
        <span style="font-size: 12pt;">
          $%s
        </span>
      </div>
    DOC

    chart.last(7).reverse.map do |tup|
      Inkblot::Components::Component.new do |cp|
        cp.body = (temp % tup.values).gsub(/\s{2,}/, '')
      end
    end
  end
end

#=== For Displaying on the EPD ===##
Inkblot::Buttons.init unless Inkblot::Buttons.ready?

@t = Inkblot::Examples::StockTicker.new(symbols: %w[AAPL FB])

begin
  Inkblot::Display.show(@t)
  loop { Inkblot::Buttons.get_press }
rescue IndexError
  Inkblot::Display.clear
  Inkblot::Buttons.release
  exit
end
