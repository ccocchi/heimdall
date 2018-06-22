module HeimdallApm
  # Stats associated with a single metric (used in metrics Hashs as value where
  # keys are the metrics names)
  #
  class MetricStats
    attr_accessor :call_count
    attr_accessor :total_call_time
    attr_accessor :total_exclusive_time
    attr_accessor :min_call_time
    attr_accessor :max_call_time

    # If this metric is scoped inside another, use exclusive time for min/max.
    # Non-scoped metrics (like Controller) track the total call time.
    def initialize(scoped: false)
      @scoped = scoped
      @call_count = 0
      @total_call_time = 0.0
      @total_exclusive_time = 0.0
      @min_call_time = 0.0
      @max_call_time = 0.0
    end

    def update(call_time, exclusive_time = nil)
      self.call_count += 1
      self.total_call_time += call_time
      self.total_exclusive_time += exclusive_time

      t = @scoped ? exclusive_time : call_time
      self.min_call_time = t if call_count == 0 || t < min_call_time
      self.max_call_time = t if t > max_call_time
    end
  end
end
