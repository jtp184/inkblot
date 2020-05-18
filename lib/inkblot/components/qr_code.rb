require 'rqrcode'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'

require_relative 'helpers/data_url'

module Inkblot
  module Components
    class QrCode < Component
      include Helpers::DataUrl

      # Sugar method for the encoded message
      def message
        options[:message]
      end

      private

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
                        if dta.margin_top
                          m << "margin-top: #{dta.margin_top}%; "
                        end

                        if dta.margin_left
                          m << "margin-left: #{dta.margin_left}%;"
                        end

                        m
                      end

        dta.data_url = data_url_from_binary(encode_message.to_png)

        dta.to_h
      end

      def encode_message
        Barby::QrCode.new(message)
      end
    end
  end
end
