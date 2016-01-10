module Seiun
  module XMLGenerators
    class BatchXML < Base
      class << self
        def add_batch(records, callback: nil)
          generator = new(callback: callback)
          generator.add_batch(records)
        end
      end

      def add_batch(records)
        sobjects = rexml_doc.add_element("sObjects", 
          "xmlns" => "http://www.force.com/2009/06/asyncapi/dataload",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance")
        records.each do |record|
          add_record(sobjects, record)
        end
        to_s
      end

      private

      def to_s
        @callback.after_build_xml(rexml_doc) if @callback
        str = super
        @rexml_doc = nil
        str
      end

      def add_record(parent, record)
        sobject = parent.add_element("sObject")
        record.to_hash.each_pair do |key, value|
          if value.is_a?(Hash)
            relation = sobject.add_element(key.to_s)
            add_record(relation, value)
          elsif value.is_a?(NilClass) || value.is_a?(String) && value.empty?
            sobject.add_element(key.to_s, "xsi:nil" => "true")
          else
            sobject.add_element(key.to_s).add_text(convert_value(value))
          end
        end
      end

      def convert_value(value)
        if value.is_a?(Time) || value.is_a?(DateTime)
          value.iso8601.to_s
        elsif value.is_a?(Date)
          value.strftime("%Y-%m-%d")
        elsif value.is_a?(Array)
          value.join(";")
        else
          value.to_s
        end
      end
    end
  end
end
