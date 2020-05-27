require 'net/http'

module Inkblot
  module Components
    module Helpers
      # Assists with using icons from familar ruby symbols
      module Icons
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

          # Predefined icon groups
          def icon_groups
            {
              default: (10_112..10_115).map { |n| :"##{n}" },
              arrows: %i[nwarr larr swarr swarr],
              arrows_out: %i[nwarr larr swarr swarr],
              arrows_in: Array.new(4) { :rarr },
              select: %i[check times uarr darr],
              confirm: %i[check times],
              agree: [:check],
              cancel: [:times]
            }.freeze
          end

          private

          # Where the codepoints file is hosted on github
          def codepoints_uri
            String.new('https://raw.githubusercontent.com/google').tap do |str|
              str << '/material-design-icons/master/iconfont/codepoints'
              URI(str)
            end
          end
        end

        # Takes in the symbol +icn+ and converts it into a material icon
        # or a basic HTML symbol if it isn't a material icon
        def html_icon_sym(icn)
          mi = material_icon_sym(icn)
          "&#{(mi || icn)};"
        end

        # Instance method that translates a symbol +icn+ into its codepoint
        def material_icon_sym(icn)
          Icons.codepoints[icn]
        end

        # Handles the work of converting user input into display logic.
        # * If no icons is given uses the default
        # * If a single symbol is given, uses the icon_groups
        # * If an array is given, runs sym args through html_sym
        # * If anything else is given it's arrayified for simplicity
        def replace_icon_groups
          ig = if options[:icons].nil?
                 Icons.icon_groups[:default]
               elsif options[:icons].is_a?(Symbol)
                 Icons.icon_groups[options[:icons]]
               elsif options[:icons].is_a?(Array)
                 options[:icons]
               else
                 Array(options[:icons])
               end

          ig.map do |ic|
            ic.is_a?(Symbol) ? html_icon_sym(ic) : ic
          end
        end
      end
    end
  end
end
