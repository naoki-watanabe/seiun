module Seiun
  class Client
    def initialize(databasedotcom: nil, batch_size: 10_000)
      @batch_size = batch_size
      @connection = Seiun::Connection.new(databasedotcom)
    end

    def insert(table_name, records, callback_class: nil, async: true)
      operate(:insert, table_name, records: records, callback: callback_class, async: async)
    end

    def insert_queue(table_name, callback_class: nil, async: true)
      @insert_queue ||= {}
      @insert_queue[table_name] ||= Seiun::Queue.new(batch_size: @batch_size) do |records|
        insert(table_name, records, callback_class: callback_class, async: async)
      end
    end

    def update(table_name, records, callback_class: nil, async: true)
      operate(:update, table_name, records: records, callback: callback_class, async: async)
    end

    def update_queue(table_name, callback_class: nil, async: true)
      @update_queue ||= {}
      @update_queue[table_name] ||= Seiun::Queue.new(batch_size: @batch_size) do |records|
        update(table_name, records, callback_class: callback_class, async: async)
      end
    end

    def upsert(table_name, records, ext_field_name, callback_class: nil, async: true)
      operate(:upsert, table_name, records: records,
        ext_field_name: ext_field_name, callback: callback_class, async: async)
    end

    def upsert_queue(table_name, ext_field_name, callback_class: nil, async: true)
      @upsert_queue ||= {}
      @upsert_queue[table_name] ||= Seiun::Queue.new(batch_size: @batch_size) do |records|
        upsert(table_name, records, ext_field_name, callback_class: callback_class, async: async)
      end
    end

    def delete(table_name, records, callback_class: nil, async: true)
      operate(:delete, table_name, records: records, callback: callback_class, async: async)
    end

    def delete_queue(table_name, callback_class: nil, async: true)
      @delete_queue ||= {}
      @delete_queue[table_name] ||= Seiun::Queue.new(batch_size: @batch_size) do |records|
        delete(table_name, records, callback_class: callback_class, async: async)
      end
    end

    def query(table_name, soql, callback_class: nil)
      operate(:query, table_name, soql: soql, callback: callback_class)      
    end

    def find_job(id, callback_class: nil)
      callback_class = wrap_callback(callback_class)
      Seiun::Job.new(@connection, id: id, callback: callback_class)
    end

    private

    def operate(operation, object, records: [], soql: "", ext_field_name: nil, callback: nil, async: true)
      return if operation != :query && records.empty?
      callback = wrap_callback(callback)
      records = records.map{|r| Seiun::Callback::RecordWrapper.new(r) }
      job = Seiun::Job.new(@connection, operation: operation, object_name: object, ext_field_name: ext_field_name, callback: callback)
      job.post_creation
      operation == :query ? job.add_query(soql) : records.each_slice(@batch_size).each{|chunk| job.add_batch(chunk) }
      job.post_closing
      job.wait_finish if async == false
      operation == :query ? job.get_results : job
    end

    def wrap_callback(callback)
      Seiun::Callback::Wrapper.new(callback) if callback
    end
  end
end
