require 'thread'
require 'heimdall/metrics_set'

module HeimdallApm
  # Keeps in RAM one or more minute's worth of metrics.
  # When informed to by the background thread, it pushes the in-RAM metrics off
  # to InfluxDB.
  class Vault
    def initialize(context)
      @context  = context
      @lock     = Mutex.new
      @spans    = Hash.new { |h, k| h[k] Span.new(k, @context) }
    end

    def current_span
      @spans[current_timestamp]
    end

    def store(metrics)
      @lock.synchronize { current_span.absorb_metrics(metrics) }
    end

    private

    def current_timestamp
      time = Time.now.utc
      time.to_i - time.sec
    end
  end

  # One span of storage
  class Span
    def initialize(timestamp, context)
      @timestamp    = timestamp
      @context      = context

      @metrics_set  = ::HeimdallApm::MetricsSet.new
    end

    def absorb_metrics(metrics)
      @metrics_set.absorb_all(metrics)
    end
  end
end
