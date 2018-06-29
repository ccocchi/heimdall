require 'heimdall_apm/metric_name'
require 'heimdall_apm/metric_stats'

module HeimdallApm
  module Visitors
    # Extract metrics for a given transaction
    #
    class RequestMetricsVisitor
      attr_reader :metrics

      def initialize(vault, transaction)
        @transaction = transaction
        @vault   = vault
        @metrics = {}
      end

      def visit(segment)
        name = ::HeimdallApm::MetricName.new(segment.type, segment.name)
        @metrics[name] ||= ::HeimdallApm::MetricStats.new

        stat = @metrics[name]
        stat.update(segment.total_call_time, segment.total_exclusive_time)
      end

      def store_in_vault
        timestamp = @transaction.root_segment.stop_time
        @vault.store_transaction_metrics(@transaction.scope, timestamp, metrics)
      end

      private def request_metric_name
        @request_metric_name ||= ::HeimdallApm::MetricName.new('Request'.freeze, 'total'.freeze)
      end
    end
  end
end
