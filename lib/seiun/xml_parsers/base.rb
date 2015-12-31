module Seiun
  module XMLParsers
    class Base
      class << self
        private

        def parse(xml_str, find_tag, block)
          callback = Proc.new {|attrs| block.call(new(attrs)) }
          listener = XMLParsers::StreamListener.new(find_tag, callback)
          REXML::Parsers::StreamParser.new(xml_str, listener).parse
        end
      end

      def initialize(attrs)
        @attrs = attrs
      end

      def to_hash(strict_mode = false)
        return {} unless @attrs.is_a?(Array)
        @attrs.each_with_object({}) do |attribute, result|
          key, values = attribute.to_a.first
          results = [values].flatten.map{|value|
            next if value.is_a?(Hash) && value["xsi:nil"] == "true"
            next value if strict_mode
            if Seiun::Utils.parsable_date?(value) && ( date = Date.parse(value, false) rescue nil )
              next date
            end
            if Seiun::Utils.parsable_time?(value) && ( time = Time.iso8601(value) rescue nil )
              next time
            end
            next true if value == "true"
            next false if value == "false"
            value
          }
          results.uniq! unless strict_mode
          result[key] = ( results.size <= 1 ? results.first : results )
        end
      end
    end
  end
end
