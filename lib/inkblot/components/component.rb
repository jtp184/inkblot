require 'erb'
require 'ostruct'

module Inkblot
  module Components
    # Base class for displayable components
    class Component
      # Options for the dynamic aspects of the content
      attr_reader :options
      # The resulting html fragment from the component
      attr_reader :html

      # Takes in options for building the component either throungh +opts+
      # or by yielding an OpenStruct to a block.
      def initialize(topts={}, kopts={}) #:yields: opts_struct
        @options = topts
        kopts.each_pair { |k, v| instance_variable_set(:"@#{k}", v) }

        if block_given?
          o = OpenStruct.new(@options)
          yield o
          @options = o.to_h
        end
      end

      # Creates a new basic component by joining the fragment maps
      # of +args+
      def self.create(*args)
        subc = args
        yield subc if block_given?
        new(body: subc.map(&:to_html_frag).join("\n"))
      end

      # Creates a new instance passing +options+ to the constructor
      def dup
        self.class.new(options)
      end

      # Returns the template
      def to_s
        template
      end

      # Lazily creates the +html+ attribute by running +build+
      def to_html
        @html ||= build
      end

      def to_html_frag
        @html_frag ||= build(false)
      end

      # Recompute +html+ from +build+
      def to_html!
        @html = build
      end

      def to_html_frag!
        @html_frag = build(false)
      end

      # Lazily gets the template from +template_path+
      def template
        @template ||= File.read(template_path)
      end

      private

      # The HTML head/body wrapper start snippet
      def self.start_component_template
        @start_component_template ||= File.read(Inkblot.vendor_path('templates', 'startComponent.html.erb'))
      end

      # The HTML head/body wrapper end snippet
      def self.end_component_template
        @end_component_template ||= File.read(Inkblot.vendor_path('templates', 'endComponent.html.erb'))
      end

      # Generic access to a height setting method
      def get_height(dta)
        if options.key?(:div_height)
          dta[:div_height] = if options[:div_height] == :full
            Display.size[:height].to_s + 'px'
          elsif options[:div_height].is_a?(Integer)
            options[:div_height].to_s + "%"
          else
            options[:div_height].to_s
          end
        else
          dta[:div_height] = "100%"
        end
      end

      # Generic access to a width setting method
      def get_width(dta)
        if options.key?(:div_width)
          dta[:div_width] = if options[:div_width] == :full
            Display.size[:width].to_s + 'px'
          elsif options[:div_height].is_a?(Integer)
            options[:div_height].to_s + "%"
          else
            options[:div_height].to_s
          end
        else
          dta[:div_width] = "100%"
        end
      end

      # Allows for virtual attributes passed to templates. Child classes should
      # override with code to create these values and return them as a hash
      def computed
        {}
      end

      # Merges together the +options+ and results for +computed+, for use in
      # the erb template
      def data
        options.merge(computed)
      end

      # Derives the template along the vendor path for this class, with lazy evaluation
      def template_base_path
        return @template_path if @template_path

        klass = self.class.name.split('::').last
        @template_path ||= Inkblot.vendor_path('templates', klass)
      end

      # Simply appends the file extension. Overridable
      def template_path
        template_base_path << '.html.erb'
      end

      # Generates HTML from the ERB template. Adds the start / end component blocks
      # if +wrap+ is true
      def build(wrap=true)
        h = []
        
        h << self.class.start_component_template if wrap
        h << template
        h << self.class.end_component_template if wrap

        h = h.join("\n")

        ERB.new(h).result(binding)
      end
    end
  end
end