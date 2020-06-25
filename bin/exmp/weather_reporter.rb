# frozen_string_literal: true

require 'inkblot'
require 'net/http'

module Inkblot
  module Examples
    # Can fetch weather from OpenWeatherMap and display it to the EPD
    # You'll need an OpenWeatherMap API key: https://home.openweathermap.org/users/sign_up
    # You can run this example with `OPEN_WEATHER_MAP_API_KEY="0123456789ABCDEFFEDCBA9876543210" ruby bin/exmp/weather_reporter.rb`
    class WeatherReporter
      # The URL to OWM's API
      API_URL = 'https://api.openweathermap.org/data/2.5/weather'

      # Takes in +opts+ which are set as ivars
      def initialize(opts = {})
        opts.each_pair { |k, v| instance_variable_set(:"@#{k}", v) }
        @api_key ||= ENV['OPEN_WEATHER_MAP_API_KEY']
        @units ||= 'imperial'
        @disp ||= :temp
      end

      # Composes and emits an IconPane component with weather data
      def to_display
        api = latest_report

        Inkblot::Components::IconPane.new do |ic|
          ic.fullscreen = ic.fixed_height = true

          ic.icons = [api[:icon], :"#8203", api[:wind_speed], api[:wind_dir]]

          ic.frame_contents = Inkblot::Components::SimpleText.new do |st|
            st.text = api[@disp]
            st.size = 60 if @disp == :temp
          end
        end
      end

      # Defines the button actions for the reporter
      # - 1: noop to refresh display
      # - 2: Swap units c/f
      # - 3: Swap temp / conditions
      # - 4: Abort display
      def button_actions
        return @button_actions if @button_actions

        @button_actions = [proc {}]

        @button_actions << proc do
          @units = swap_units(@units || 'imperial')
        end

        @button_actions << proc do
          @disp = @disp == :temp ? :desc : :temp
        end

        @button_actions << proc do
          raise IndexError, 'Cancel button was pressed'
        end
      end

      # Fetch the api data and return this object
      def refresh
        fetch_api_data
        self
      end

      # Most recently pulled info
      def latest_report
        @latest_report || fetch_api_data
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

      # Flips imperial and metric
      def swap_units(unit)
        case unit
        when 'imperial'
          'metric'
        when 'metric'
          'imperial'
        end
      end

      # Retrieves JSON payload of API data and converts it into a simplified hash
      def fetch_api_data
        addr = URI(API_URL)
        addr.query = URI.encode_www_form(form_params.transform_keys(&:to_s))

        data = JSON.parse(Net::HTTP.get(addr))

        @latest_report = {
          temp: data['main']['temp'].round.to_s + '&deg;',
          desc: data['weather'][0]['description'],
          icon: weather_icon(data['weather'][0]['icon'][0..-2].to_i),
          wind_speed: data['wind']['speed'].floor,
          wind_dir: compass_dir(data['wind']['deg'])
        }
      end

      # Composes the form params out of the location args, units, and api_key
      def form_params
        location_args.merge(units: @units, appid: @api_key)
      end
    end
  end
end

class Inkblot::Examples::WeatherReporter
  class << self
    def run
      # For Displaying on the EPD
      Inkblot::Buttons.init unless Inkblot::Buttons.ready?
      @w = Inkblot::Examples::WeatherReporter.new(zip_code: '90210')

      refresh_time = 15 * 60

      begin
        loop do
          Inkblot::Display.show(@w)
          Inkblot::Buttons.get_press(refresh_time)

          @w.refresh

          puts
          puts Time.now, @w.latest_report
        end
      rescue IndexError
        Inkblot::Display.clear
        Inkblot::Buttons.release
        exit
      end
    end
  end
end

Inkblot::Examples::WeatherReporter.run
