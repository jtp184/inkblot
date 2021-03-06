# frozen_string_literal: true

require 'inkblot'
require 'json'
require 'pry'

module Inkblot
  module Examples
    # Display Pihole stats
    class PiholeChronometer
      # Returns a simple text
      def to_display
        Inkblot::Components::SimpleText.new do |st|
          st.fullscreen = true
          st.text = @chronometer[:ads_blocked_today].to_s
          st.size = 40
        end
      end

      # Top 3 refresh, last one exists
      def button_actions
        return @button_actions if @button_actions

        @button_actions = Array.new(3, method(:refresh))
        @button_actions << proc do
          raise IndexError, 'Cancel button was pressed'
        end
      end

      # Read the chronometer
      def refresh
        read_chronometer
        self
      end

      private

      # Read JSON data from the pihole command
      def read_chronometer
        @chronometer = JSON.parse(`pihole chronometer -j`)
                           .transform_keys(&:to_sym)
      end
    end
  end
end

class Inkblot::Examples::PiholeChronometer
  class << self
    # For Displaying on the EPD
    def run
      Inkblot::Buttons.init unless Inkblot::Buttons.ready?

      @c = Inkblot::Examples::PiholeChronometer.new.refresh

      refresh_time = 60 * 60

      begin
        loop do
          Inkblot::Display.show(@c)
          Inkblot::Buttons.get_press(refresh_time)
        end
      rescue IndexError
        Inkblot::Display.clear
        Inkblot::Buttons.release
      end
    end
  end
end

Inkblot::Examples::PiholeChronometer.run