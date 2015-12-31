module Seiun
  module XMLParsers
    class RecordXML < Base
      class << self
        def each(xml_str, find_tag: "records", &block)
          parse(xml_str, find_tag, block)
        end
      end

      def to_hash(strict_mode = false)
        source = super
        source.keys.find_all{|key| key =~ /(^[A-Z]|__c$)/ }.each_with_object({}) do |key, hash|
          hash[key] = source[key]
        end
      end
    end
  end
end
