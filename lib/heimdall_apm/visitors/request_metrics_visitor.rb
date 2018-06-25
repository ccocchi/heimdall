require 'heimdall_apm/metric_name'
require 'heimdall_apm/metric_stats'

module HeimdallApm
  module Visitors
    class RequestMetricsVisitor
      def initialize(vault, scope = nil)
        @vault    = vault
        @scope    = scope
        @metrics  = {}
      end

      def visit(segment)
        name = ::HeimdallApm::MetricName.new(segment.type, segment.name, scope)
        @metrics[name] ||= ::HeimdallApm::MetricStats.new(scoped: scope != nil)

        stat = @metrics[name]
        stat.update(total_call_time, total_exclusive_time)
      end

      def store_in_vault
        @vault.store(@metrics)
      end

    end
  end
end
