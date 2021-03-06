# frozen_string_literal: true

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
    ROOT_METRICS = ['Sql', 'Elastic', 'Redis'].map do |key|
      downcased = key.downcase
      [key, ["#{downcased}_time", "#{downcased}_count"]]
    end.to_h

    def initialize
      @points = []
    end

    def empty?
      @points.empty?
    end

    def to_a
      @points
    end

    # TODO: this looks very custom, need to find a way to better map a txn and
    # its segment into InfluxDB.
    def append(txn, metrics)
      timestamp   = txn.root_segment.stop_time
      series_name = txn.custom_series_name || (txn.web? ? 'app' : 'job')
      values      = Hash.new { |h, k| h[k] = 0 }

      tags = txn.tags || {}
      tags[:endpoint] = txn.scope

      metrics.each do |meta, stat|
        if ROOT_METRICS.key?(meta.type)
          time_key, count_key = ROOT_METRICS[meta.type]

          values[time_key]  += stat.total_exclusive_time
          values[count_key] += stat.call_count
        else
          values['ruby_time'] += stat.total_exclusive_time
        end

        values['total_time'] += stat.total_exclusive_time
      end

      values['latency'] = txn.annotations[:latency] if txn.annotations[:latency]

      # Segment time are in seconds, store them in milliseconds
      values.transform_values! { |v| v.is_a?(Integer) ? v : v * 1000 }

      @points << {
        series: series_name,
        timestamp: (timestamp * 1000).to_i,
        tags: tags,
        values: values
      }
    end
  end
end
