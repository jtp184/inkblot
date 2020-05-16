# frozen_string_literal: true

require 'inkblot'
require 'net/http'

# Can fetch weather from OpenWeatherMap and display it to the EPD
class WeatherReporter
  # The URL to OWM's API
  API_URL = 'https://api.openweathermap.org/data/2.5/weather'

  # Takes in +opts+ which are set as ivars
  def initialize(opts = {})
    opts.each_pair { |k, v| instance_variable_set(:"@#{k}", v) }
    @api_key ||= ENV['OPEN_WEATHER_MAP_API_KEY']
  end

  # Composes and emits an IconPane component with weather data
  def to_display
    api = latest_report

    Inkblot::Components::IconPane.new do |ic|
      ic.fullscreen = true
      ic.fixed_height = true

      ic.icons = [api[:icon], :"#8203", api[:wind_speed], api[:wind_dir]]
      ic.icon_size = [30, 30, 18, 30]

      ic.frame_contents = Inkblot::Components::SimpleText.new(
        text: "#{api[:temp]}&deg;", size: 60
      )
    end
  end

  # Fetch the api data and return this object
  def refresh
    fetch_api_data
    self
  end

  # Most recently pulled info
  def latest_report
    return @latest_report if @latest_report

    fetch_api_data
  end

  private

  # Return the given location parameter in order of specificity
  def location_args
    return { id: @city_id } if @city_id
    return { q: @query } if @query
    return { zip: @zip_code } if @zip_code
    return { lat: @latitude, lon: @longitude } if @latitude && @longitude
  end

  # Takes in the OWM icon number +icn+ and picks an HTML symbol based on it
  def weather_icon(icn)
    case icn
    when 1
      # Sunny
      :"#9728"
    when 2, 3, 4
      # Cloudy
      :"#9729"
    when 9, 10, 11
      # Rainy
      :"#9730"
    when 13
      # Snowy
      :"#9731"
    when 50
      # Foggy
      :"#9729"
    end
  end

  # Takes in degrees +deg+ and returns an arrow pointing that way
  def compass_dir(deg)
    case deg
    when 0..45
      :uarr
    when 46..90
      :nearr
    when 91..135
      :rarr
    when 136..180
      :searr
    when 181..225
      :darr
    when 226..270
      :swarr
    when 271..315
      :larr
    when 316..360
      :nwarr
    end
  end

  # Retrieves JSON payload of API data and converts it into a simplified hash
  def fetch_api_data
    addr = URI(API_URL)
    addr.query = URI.encode_www_form(form_params.transform_keys(&:to_s))

    data = JSON.parse(Net::HTTP.get(addr))

    @latest_report = {
      temp: data['main']['temp'].round,
      icon: weather_icon(data['weather'][0]['icon'][0..-2].to_i),
      wind_speed: data['wind']['speed'].floor,
      wind_dir: compass_dir(data['wind']['deg'])
    }
  end

  # Composes the form params out of the location args, units, and api_key
  def form_params
    location_args.merge(units: (@units || 'imperial'), appid: @api_key)
  end
end

##=== For Displaying on the EPD ===##
# @w = WeatherReporter.new(zip_code: "90210")

# refresh_time = 15 * 60
# delay_time = 5

# loop do
#   Inkblot::Display.show(@w.refresh)

#   if Inkblot::Buttons.get_input(delay_time)
#     break @w.latest_report
#   else
# 	  sleep(refresh_time - delay_time)
#   end
# end
