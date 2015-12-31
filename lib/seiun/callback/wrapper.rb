module Seiun
  module Callback
    class Wrapper
      def initialize(callback_class)
        @class = callback_class
      end

      def after_build_xml(xml)
        return unless callback_defined?(:after_build_xml)
        @class.__send__(callbacks[:after_build_xml], xml)
      end

      def before_request(request_type, path, request_body)
        return unless callback_defined?(:before_request)
        @class.__send__(callbacks[:before_request], request_type, path, request_body)
      end

      def after_response(request_type, path, response_body)
        return unless callback_defined?(:after_response)
        @class.__send__(callbacks[:after_response], request_type, path, response_body)
      end

      def ssl_verify_none
        return unless callback_defined?(:ssl_verify_none)
        @class.__send__(callbacks[:ssl_verify_none])
      end

      def mock_response_create_job
        return unless callback_defined?(:mock_response_create_job)
        @class.__send__(callbacks[:mock_response_create_job])
      end

      def mock_response_close_job
        return unless callback_defined?(:mock_response_close_job)
        @class.__send__(callbacks[:mock_response_close_job])
      end

      def mock_response_add_query
        return unless callback_defined?(:mock_response_add_query)
        @class.__send__(callbacks[:mock_response_add_query])
      end

      def mock_response_add_batch
        return unless callback_defined?(:mock_response_add_batch)
        @class.__send__(callbacks[:mock_response_add_batch])
      end

      def mock_response_get_job_details
        return unless callback_defined?(:mock_response_get_job_details)
        @class.__send__(callbacks[:mock_response_get_job_details])
      end

      def mock_response_get_batch_details
        return unless callback_defined?(:mock_response_get_batch_details)
        @class.__send__(callbacks[:mock_response_get_batch_details])
      end

      def mock_response_get_result
        return unless callback_defined?(:mock_response_get_result)
        @class.__send__(callbacks[:mock_response_get_result])
      end

      def mock_response_get_query_result
        return unless callback_defined?(:mock_response_get_query_result)
        @class.__send__(callbacks[:mock_response_get_query_result])
      end

      private

      def callback_defined?(name)
        !!callbacks[name]
      end

      def callbacks
        return {} unless @class.respond_to?(:seiun_callbacks)
        return {} unless @class.seiun_callbacks.is_a?(Hash)
        @class.seiun_callbacks
      end
    end
  end
end
