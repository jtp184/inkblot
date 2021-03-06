require 'psych'

module Inkblot
  module Components
    module Helpers
      # Assists with using icons from familar ruby symbols
      module Icons
        class << self
          # Keeps a hash of codepoints mapping friendly names of icons to their
          # HTML symbol representation. Reads from a YAML file
          def codepoints
            return @codepoints if @codepoints

            fp = Inkblot.vendor_path('codepoints.yml')
            @codepoints = Psych.load(File.read(fp))
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
        end

        # Takes in the symbol +icn+ and converts it into a material icon
        # or a basic HTML symbol if it isn't a material icon
        def html_icon_sym(icn)
          mi = material_icon_sym(icn)
          "&#{(mi || icn.to_s)};"
        end

        # Instance method that translates a symbol +icn+ into its codepoint
        def material_icon_sym(icn)
          ic = Icons.codepoints[icn]

          return unless ic

          mi = -'Material Icons'
          options[:gfonts] ||= [mi]
          options[:gfonts] << mi unless options[:gfonts].include?(mi)
          ic
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
