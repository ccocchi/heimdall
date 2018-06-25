module HeimdallApm
  # Aggregate MetricStats from different request into a single hash
  #
  class MetricsSet
    def initialize
      @metrics = {}
    end

    def absorb_all(metrics)
      metrics.each { |meta, stat| absorb(meta, stat) }
    end
  end
end
