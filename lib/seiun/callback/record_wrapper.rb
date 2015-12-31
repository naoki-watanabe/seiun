module Seiun
  module Callback
    class RecordWrapper
      def initialize(record)
        @record = record
      end

      def to_hash
        if callback_defined?(:hashalize)
          @record.__send__(:hashalize)
        elsif @record.respond_to?(:to_hash)
          @record.to_hash
        else
          @record
        end
      end

      private

      def callback_defined?(name)
        !!callbacks[name]
      end

      def callbacks
        return {} unless @record.class.respond_to?(:seiun_callbacks)
        return {} unless @record.class.seiun_callbacks.is_a?(Hash)
        @record.class.seiun_callbacks
      end
    end
  end
end
