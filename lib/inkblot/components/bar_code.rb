require 'barby/barcode/ean_13'
require 'barby/outputter/png_outputter'

module Inkblot
  module Components
    # For generating 1D UPC style codes
    class BarCode < Component
      # Sugar method for the code contents
      def code
        options[:code]
      end

      private

      # Handles sizing and margins, and creates the data url
      def computed
        dta = OpenStruct.new

        get_width(dta)
        get_height(dta)

        dta.margin_top = options.fetch(:margin_top, 0)
        dta.margin_left = options.fetch(:margin_left, 0)

        dta.margins = if dta.margin_top.zero? && dta.margin_left.zero?
                        ''
                      else
                        m = +' '
                        m << "margin-top: #{dta.margin_top}%; " if dta.margin_top
                        m << "margin-left: #{dta.margin_left}%;"if dta.margin_left

                        m
                      end

        dta.data_url = Converters::DataUrlConverter.call(
          input: generate_code.to_png(height: 60),
          format: :binary,
          filetype: 'png'
        )

        dta.to_h
      end

      # Uses Barby to encode the code as an EAN-13
      def generate_code
        Barby::EAN13.new(code)
      end
    end
  end
end
