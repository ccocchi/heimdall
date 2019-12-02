require 'heimdall_apm/metric_name'
require 'heimdall_apm/metric_stats'

module HeimdallApm
  module Visitors
    # Extract metrics for a given transaction
    #
    class DatabaseVisitor
      attr_reader :metrics

      def initialize(vault, transaction)
        @transaction = transaction
        @vault   = vault
        @metrics = {}
      end

      def visit(segment)
      end
    end
  end
end
