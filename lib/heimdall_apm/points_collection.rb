# frozen_string_literal: true

require 'set'

module HeimdallApm
  # Convert metrics hash from requests into an collection of points we want to
  # track, but without aggregations and percentiles/std_dev calculations of same
  # endpoints across multiples requests. These operations are deferred to
  # InfluxDB, in favor of more granular data.
  # This may change in the future if it proves non scalable.
  #
  class PointsCollection
    # Metrics we want to explicitely keep separated into measurements. Everything
    # else will be label as Ruby.
    ROOT_METRICS = Set.new(['Sql', 'Elastic', 'Redis'])

    def initialize
      @points = []
    end

    def empty?
      @points.empty?
    end

    def to_a
      @points
    end

    def append(txn, metrics)
      scope       = txn.scope
      timestamp   = txn.root_segment.stop_time
      series_name = txn.web? ? 'app' : 'job'
      values      = Hash.new { |h, k| h[k] = 0 }

      metrics.each do |meta, stat|
        if ROOT_METRICS.include?(meta.type)
          key = -"#{meta.type.downcase}_time"
          values[key] += stat.total_exclusive_time
        else
          values['ruby_time'] += stat.total_exclusive_time
        end

        values['total_time'] += stat.total_exclusive_time
      end

      @points << {
        series: series_name,
        timestamp: (timestamp * 1000).to_i,
        tags: { endpoint: scope },
        values: values
      }
    end
  end
end
