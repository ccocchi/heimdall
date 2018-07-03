require 'thread'
require 'heimdall_apm/points_collection'

module HeimdallApm
  # Keeps in RAM one or more minute's worth of metrics.
  # When informed to by the background thread, it pushes the in-RAM metrics off
  # to InfluxDB.
  class Vault
    def initialize(context)
      @context  = context
      @lock     = Mutex.new
      @spans    = Hash.new { |h, k| h[k] = Span.new(k, @context) }
    end

    def current_span
      @spans[current_timestamp]
    end

    def retrieve_and_delete_previous_span
      timestamp = current_timestamp - 60
      @lock.synchronize { @spans.delete(timestamp) }
    end

    def store_transaction_metrics(txn, metrics)
      @lock.synchronize { current_span.add_point(txn, metrics) }
    end

    def current_timestamp
      time = Time.now.utc
      time.to_i - time.sec
    end
  end

  # One span of storage
  class Span
    attr_reader :points_collection

    def initialize(timestamp, context)
      @timestamp = timestamp
      @context   = context

      @points_collection = ::HeimdallApm::PointsCollection.new
    end

    def add_point(txn, metrics)
      @points_collection.append(txn, metrics)
    end
  end
end
