require 'net/http'

module Inkblot
  module Components
    module Helpers
      # Assists with using Google Material Design icons
      module MaterialIcons
        class << self
          # Keeps a hash of codepoints mapping friendly names of icons to their
          # HTML symbol representation. Fetches from the web once per session.
          def codepoints
            return @codepoints unless @codepoints.nil?

            raw = Net::HTTP.get(codepoints_uri)

            @codepoints = raw.scan(/(\w+) (\w+)/)
                             .to_h
                             .transform_keys(&:to_sym)
                             .transform_values { |v| :"#x#{v.upcase}" }
          end

          private

          # Where the codepoints file is hosted on github
          def codepoints_uri
            uri = 'https://raw.githubusercontent.com/google'
            uri << '/material-design-icons/master/iconfont/codepoints'
            URI(uri)
          end
        end

        # Instance method that translates a symbol +icn+ into its codepoint
        def material_icon_sym(icn)
          MaterialIcons.codepoints[icn]
        end
      end
    end
  end
end
