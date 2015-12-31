module Seiun
  module XMLParsers
    class BatchXML < Base
      class << self
        def each(xml_str, &block)
          parse(xml_str, "batchInfo", block)
        end
      end

      [ :id, :job_id, :state, :created_date, :system_modstamp ].each do |name|
        define_method name do
          to_hash(true)[Seiun::Utils.camelize(name)]
        end
      end
    end
  end
end
