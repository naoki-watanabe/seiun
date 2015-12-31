module Seiun
  module XMLGenerators
    class JobXML < Base
      class << self
        def create_job(operation, object, ext_field_name: nil, callback: nil)
          generator = new(callback: callback)
          generator.create_job(operation, object, ext_field_name: ext_field_name)
        end

        def close_job(callback: nil)
          generator = new(callback: callback)
          generator.close_job
        end
      end

      def create_job(operation, object, ext_field_name: nil)
        create_job_info do |jobinfo|
          jobinfo.add_element("operation").add_text(operation.to_s)
          jobinfo.add_element("object").add_text(object.to_s)
          jobinfo.add_element("externalIdFieldName").add_text(ext_field_name.to_s) if ext_field_name
          jobinfo.add_element("contentType").add_text("XML")
        end
        to_s
      end

      def close_job
        create_job_info do |jobinfo|
          jobinfo.add_element("state").add_text("Closed")
        end
        to_s
      end

      private

      def create_job_info
        jobinfo = rexml_doc.add_element("jobInfo", 
          "xmlns" => "http://www.force.com/2009/06/asyncapi/dataload",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance")
        yield(jobinfo)
      end
    end
  end
end
