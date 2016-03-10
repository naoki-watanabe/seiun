module Seiun
  class Queue
    def initialize(batch_size: 10_000, &operation)
      @batch_size = batch_size
      @operation = operation
      initialize_queue
      @jobs = []
    end

    def <<(record)
      push(record)
    end

    def push(record)
      @queue << record
      operate if @queue.size == @batch_size
      record
    end

    def close
      operate
      @jobs.compact
    end

    private

    def operate
      @jobs << @operation.call(@queue)
      initialize_queue
    end

    def initialize_queue
      @queue = []
    end
  end
end
