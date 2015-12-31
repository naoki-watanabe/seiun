module Seiun
  module XMLParsers
    class StreamListener
      include REXML::StreamListener

      def initialize(find_tag, callback)
        @find_tag = find_tag
        @callback = callback
        @stack = []
      end

      def tag_start(name, attrs)
        if @stack.empty? && name == @find_tag
          element = []
          element << attrs unless attrs.empty?
          @current = element
          @stack = [ element ]
        elsif @current
          element = []
          element << attrs unless attrs.empty?
          @stack.last << { name => element }
          @stack.push(element)
        end
      end

      def text(text)
        text = text.strip
        return if text.empty?
        @stack.last << text if @current
      end

      def tag_end(name)
        if @stack.size == 1 && name == @find_tag
          @callback.call(@current)
          @current, @stack = nil, []
        elsif @current
          pop_tag = @stack.pop
        end
      end
    end
  end
end
