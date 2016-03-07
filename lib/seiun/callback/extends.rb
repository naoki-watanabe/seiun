module Seiun
  module Callback
    module Extends
      module ClassMethods
        [ :after_create_job, :after_close_job, :hashalize,
          :before_build_xml, :after_build_xml, :before_request, :after_response, :ssl_verify_none,
          :mock_response_create_job, :mock_response_close_job, :mock_response_add_query, :mock_response_add_batch,
          :mock_response_get_job_details, :mock_response_get_batch_details, :mock_response_get_result, :mock_response_get_query_result
        ].each do |callback_point|
          define_method "seiun_#{callback_point}" do |method_name|
            @seiun_callbacks ||= {}
            @seiun_callbacks[callback_point] = method_name
          end
        end

        def seiun_callbacks
          @seiun_callbacks
        end
      end

      extend ClassMethods

      def self.included(klass)
        klass.extend ClassMethods
      end
    end
  end
end
