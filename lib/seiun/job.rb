module Seiun
  class Job
    attr_reader :operation

    def initialize(connection, operation, object_name, id: nil, ext_field_name: nil, callback: nil)
      @connection = connection
      @operation = operation
      @object_name = object_name
      @id = id if id
      @ext_field_name = ext_field_name if ext_field_name
      @callback = callback
      @batches = []
    end

    def post_creation
      response_body = @connection.create_job(create_job_xml, callback: @callback)
      parse_job_xml(response_body)
    end

    def post_closing
      response_body = @connection.close_job(close_job_xml, @id, callback: @callback)
      parse_job_xml(response_body)
    end

    def add_query(soql)
      response_body = @connection.add_query(soql, @id, callback: @callback)
      parse_batch_xml(response_body)
    end

    def add_batch(records)
      response_body = @connection.add_batch(add_batch_xml(records), @id, callback: @callback)
      parse_batch_xml(response_body)
    end

    def get_batch_details
      response_body = @connection.get_batch_details(@id, callback: @callback)
      parse_batch_xml(response_body)
    end

    def get_query_result
      result = []
      @batches.each do |batch|
        result_response_body = @connection.get_result(@id, batch.id, callback: @callback)
        Seiun::XMLParsers::ResultXML.each(result_response_body) do |result_response|
          response_body = @connection.get_query_result(@id, batch.id, result_response.result_id, callback: @callback)
          Seiun::XMLParsers::RecordXML.each(response_body) do |response|
            result << response.to_hash
          end
        end
      end
      result
    end

    def all_batch_finished?
      raise "Batches are empty" if @batches.empty?
      @batches.all?{|batch| !["Queued", "InProgress"].include?(batch.sf_state) }
    end

    private

    def create_job_xml
      Seiun::XMLGenerators::JobXML.create_job(@operation, @object_name, ext_field_name: @ext_field_name, callback: @callback)
    end

    def close_job_xml
      Seiun::XMLGenerators::JobXML.close_job(callback: @callback)
    end

    def add_batch_xml(records)
      Seiun::XMLGenerators::BatchXML.add_batch(records, callback: @callback)
    end

    def parse_job_xml(response_body)
      Seiun::XMLParsers::JobXML.each(response_body) do |response|
        @id = response.id || @id
        @sf_created_at = response.created_date || @sf_created_at
        @sf_updated_at = response.system_modstamp || @sf_updated_at
        @sf_state = response.state || @sf_state
      end
    end

    def parse_batch_xml(response_body)
      Seiun::XMLParsers::BatchXML.each(response_body) do |response|
        unless batch = @batches.find{|batch| batch.id == response.id }
          batch = Batch.new(response.id)
          @batches << batch
        end
        batch.job_id = response.job_id || batch.job_id
        batch.sf_state = response.state || batch.sf_state
        batch.sf_created_at = response.created_date || batch.sf_created_at
        batch.sf_updated_at = response.system_modstamp || batch.sf_updated_at
      end
    end

    class Batch
      attr_reader :id
      attr_accessor :job_id, :sf_state, :sf_created_at, :sf_updated_at, :number_records_processed

      def initialize(id)
        @id = id
      end
    end
  end
end
