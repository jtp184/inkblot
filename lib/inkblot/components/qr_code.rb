require 'rqrcode'
require 'base64'

module Inkblot
  module Components
    # Render and display QR Codes
    class QrCode < Component
      # Sugar method for the encoded message
      def message
        options[:message]
      end

      private

      # Sets the margins and sizing
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

        dta.to_h
      end

      # Converts the encoded message to png and emits it as a data url
      def png_data
        encode_message.as_png(size: 512, border_modules: 0).to_data_url
      end

      # Encodes the message using the rqrcode library
      def encode_message
        RQRCode::QRCode.new(message)
      end
    end
  end
end
