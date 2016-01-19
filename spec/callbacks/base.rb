module SeiunSpec
  module Callbacks
    class Base
      include Seiun::Callback::Extends
  
      seiun_before_build_xml :before_build_xml
      seiun_after_build_xml :after_build_xml
      seiun_before_request :before_request
      seiun_after_response :after_response
      seiun_ssl_verify_none :ssl_verify_none?

      class << self
        attr_reader :paths, :requests, :responses, :records, :xml_size

        def init
          @paths, @requests, @responses, @records, @xml_size = nil, nil, nil, nil, nil
        end

        private

        def before_build_xml(records)
          @records = records
        end

        def after_build_xml(xml_doc)
          @xml_size = REXML::XPath.match(xml_doc, "/sObjects/sObject").size
        end

        def before_request(type, path, body)
          @paths ||= {}
          @paths[type] ||= []
          @paths[type] << path
          @requests ||= {}
          @requests[type] ||= []
          @requests[type] << body
        end

        def after_response(type, path, body)
          @responses ||= {}
          @responses[type] ||= []
          @responses[type] << body
        end

        def ssl_verify_none?
          true
        end
      end

      def initialize(hash)
        @hash = hash
      end

      def hashalize
        @hash
      end
    end
  end
end
