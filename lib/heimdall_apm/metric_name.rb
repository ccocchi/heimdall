module HeimdallApm
  # Metric name used in visitor's metrics hash
  #
  class MetricName
    def initialize(type, name, scope = nil)
      @type   = type
      @name   = name
      @scope  = scope
    end

    def hash
      h = type.hash ^ name.hash
      h ^= scope.hash if hash
      h
    end
  end
end
