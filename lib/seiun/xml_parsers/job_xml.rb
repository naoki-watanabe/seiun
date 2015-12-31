module Seiun
  module XMLParsers
    class JobXML < Base
      class << self
        def each(xml_str, &block)
          parse(xml_str, "jobInfo", block)
        end
      end

      [ :id, :operation, :object, :created_by_id, :created_date, :system_modstamp,
        :state, :content_type, :external_id_field_name
      ].each do |name|
        define_method name do
          to_hash(true)[Seiun::Utils.camelize(name)]
        end
      end
    end
  end
end
