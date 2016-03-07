module Seiun
  class Job
    SEC_TO_WAIT = 60*10  # 10 minutes
    private_constant :SEC_TO_WAIT

    attr_reader :id

    def initialize(connection, operation: nil, object_name: nil, id: nil, ext_field_name: nil, callback: nil)
      @connection = connection
      @operation = operation.to_sym if operation
      @object_name = object_name.to_s if object_name
      @id = id
      @ext_field_name = ext_field_name
      if callback
        callback.job = self
        @callback = callback
      end
      @batches = []
    end

    def post_creation
      response_body = @connection.create_job(create_job_xml, callback: @callback)
      parse_job_xml(response_body)
      @callback.after_create_job(self) if @callback
    end

    def post_closing
      response_body = @connection.close_job(close_job_xml, @id, callback: @callback)
      parse_job_xml(response_body)
      @callback.after_close_job(self) if @callback
    end

    def add_query(soql)
      response_body = @connection.add_query(soql, @id, callback: @callback)
      parse_batch_xml(response_body)
    end

    def add_batch(records)
      response_body = @connection.add_batch(add_batch_xml(records), @id, callback: @callback)
      parse_batch_xml(response_body)
    end

    def each_result
      wait_finish
      batches.each do |batch|
        result_response_body = @connection.get_result(@id, batch.id, callback: @callback)
        Seiun::XMLParsers::ResultXML.each(result_response_body) do |result_response|
          if query?
            response_body = @connection.get_query_result(@id, batch.id, result_response.result_id, callback: @callback)
            Seiun::XMLParsers::RecordXML.each(response_body) do |response|
              yield(response.to_hash)
            end
          else
            yield(result_response.to_hash)
          end
        end
      end
    end

    def get_results
      results = []
      each_result{|res| results << res }
      results
    end

    def object_name(get: true)
      return @object_name if @object_name || get == false
      get_job_details
      @object_name
    end

    def operation(get: true)
      return @operation if @operation || get == false
      get_job_details
      @operation
    end

    def sf_state(get: true)
      return @sf_state if @sf_state || get == false
      get_job_details
      @sf_state
    end

    def batches(get: true)
      return @batches if !@batches.empty? || get == false
      get_batch_details
      @batches
    end

    def wait_finish
      Timeout.timeout(sec_to_wait_finish) do
        until closed?
          get_job_details
          sleep 1
        end
        until all_batch_finished?
          get_batch_details
          sleep 1
        end
      end
    end

    def closed?
      sf_state == "Closed"
    end

    private

    def get_job_details
      response_body = @connection.get_job_details(@id, callback: @callback)
      parse_job_xml(response_body)
    end

    def get_batch_details
      response_body = @connection.get_batch_details(@id, callback: @callback)
      parse_batch_xml(response_body)
    end

    def create_job_xml
      Seiun::XMLGenerators::JobXML.create_job(@operation, @object_name, ext_field_name: @ext_field_name, callback: @callback)
    end

    def close_job_xml
      Seiun::XMLGenerators::JobXML.close_job(callback: @callback)
    end

    def add_batch_xml(records)
      @callback.before_build_xml(records) if @callback
      Seiun::XMLGenerators::BatchXML.add_batch(records, callback: @callback)
    end

    def parse_job_xml(response_body)
      Seiun::XMLParsers::JobXML.each(response_body) do |response|
        @id ||= response.id
        @operation = ( @operation || response.operation ).to_sym
        @object_name ||= response.object
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
        batch.sf_state_message = response.state_message || batch.sf_state_message
        batch.sf_created_at = response.created_date || batch.sf_created_at
        batch.sf_updated_at = response.system_modstamp || batch.sf_updated_at
        raise Seiun::BatchFailError, response.state_message if response.state == "Failed"
      end
    end

    def sec_to_wait_finish
      SEC_TO_WAIT
    end

    [ :insert, :update, :upsert, :delete, :query ].each do |symbol|
      define_method "#{symbol}?" do
        @operation == symbol
      end
    end

    def all_batch_finished?
      return true if batches.empty?
      batches.all?{|batch| !["Queued", "InProgress"].include?(batch.sf_state) }
    end

    class Batch
      attr_reader :id
      attr_accessor :job_id, :sf_state, :sf_state_message, :sf_created_at, :sf_updated_at, :number_records_processed

      def initialize(id)
        @id = id
      end
    end
  end
end
