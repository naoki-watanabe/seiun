module SeiunSpec
  module Callbacks
    class Base
      include Seiun::Callback::Extends
  
      seiun_before_request :before_request
      seiun_after_response :after_response
      seiun_ssl_verify_none :ssl_verify_none?

      class << self
        attr_reader :paths, :requests, :responses

        def init
          @paths, @requests, @responses = nil, nil, nil
        end

        private

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
