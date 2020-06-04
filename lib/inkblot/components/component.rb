require 'erb'
require 'ostruct'

module Inkblot
  module Components
    # Base class for displayable components
    class Component
      # Options for the dynamic aspects of the content
      attr_reader :options

      # Takes in options for building the component either throungh +opts+
      # or by yielding an OpenStruct to a block.
      def initialize(topts = {}, kopts = {}) #:yields: opts_struct
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

      # Lazily creates the html by running +build+
      def to_html
        build
      end

      # Non-standalone, doesn't wrap with HTML and head tags
      def to_html_frag
        build(false)
      end

      # Returns a new HtmlConverter with the result of #to_html
      def convert
        Converters::HtmlConverter.new(input: to_html)
      end

      # Lazily gets the template from +template_path+
      def template
        @template ||= File.read(template_full_path)
      end

      private

      # The HTML head/body wrapper start snippet
      def self.start_component_template
        @start_component_template ||= File.read(
          Inkblot.vendor_path('templates', 'startComponent.html.erb')
        )
      end

      # The HTML head/body wrapper end snippet
      def self.end_component_template
        @end_component_template ||= File.read(
          Inkblot.vendor_path('templates', 'endComponent.html.erb')
        )
      end

      # Generic access to a height setting method
      def get_height(dta)
        get_dimension('height', dta)
      end

      # Generic access to a width setting method
      def get_width(dta)
        get_dimension('width', dta)
      end

      # DRYs out the width and height calls
      def get_dimension(dim, dta)
        dim_div = :"div_#{dim}"
        dim_sym = dim.to_sym

        dta[dim_div] = if options.key?(:fullscreen)
                         Display.size[dim_sym].to_s + 'px'
                       elsif options.key?(dim_div)
                         if options[dim_div] == :full
                           Display.size[dim_sym].to_s + 'px'
                         elsif options[dim_div].is_a?(Integer)
                           options[dim_div].to_s + '%'
                         else
                           options[dim_div].to_s
                         end
                       else
                         '100%'
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

      # The resolved path to the template file, broken out so both parts
      # can be overridden
      def template_full_path
        @template_full_path ||= [template_base_path, template_filename].join('/')
      end

      # Overridable, returns the vendor path templates directory
      def template_base_path
        @template_base_path ||= Inkblot.vendor_path('templates')
      end

      # Yields the overridable instance variable, or sets it to the class name
      def template_filename
        @template_filename ||= self.class.name.split('::').last + -'.html.erb'
      end

      # Generates HTML from the ERB template. Adds the start / end component blocks
      # if +wrap+ is true
      def build(wrap = true)
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
