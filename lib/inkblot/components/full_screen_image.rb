module Inkblot
  module Components
    class FullScreenImage < Component
      IMG_SOURCES = %i[url path file]

      def initialize(*args)
        super
        raise ArgumentError unless options.keys.any? { |k| IMG_SOURCES.include?(k) }
      end

      def to_display
        case img_src
        when :url
          HtmlConverter.new(input: options[:url])
        when :path
          ImageConverter.new(input: options[:path])
        when :file
          ImageConverter.new(input: options[:file])
        end
      end

      private

      def img_src
        options.keys.find { |o| IMG_SOURCES.include?(o) }
      end
    end
  end
end