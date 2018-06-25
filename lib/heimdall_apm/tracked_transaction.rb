require 'heimdall_apm/visitors/request_metrics_visitor'
require 'heimdall_apm/visitors/pretty_print_visitor'

module HeimdallApm
  # A TrackedTransaction is a collection of segments.
  #
  class TrackedTransaction

    # First segment added to the transaction
    attr_reader :root_segment

    # Recorder used to process transaction data
    attr_reader :recorder

    # Scope of this transaction (controller routes / job id)
    attr_accessor :scope

    def initialize(context)
      @context      = context
      @root_segment = nil
      @segments     = []
      @scope        = nil

      @recorder     = context.recorder
      @vault        = context.vault
    end

    def start_segment(segment)
      @root_segment = segment unless @root_segment
      @segments.push(segment)
    end

    def stop_segment
      segment = @segments.pop
      segment.record_stop_time

      if finalized?
        stop_request
      else
        @segments[-1].add_child(segment)
      end
    end

    # Grab the currently running segment. Will be `nil` for a finalized
    # transaction
    def current_segment
      @segments[-1]
    end

    VISITORS = {
      metrics: ::HeimdallApm::Visitors::RequestMetricsVisitor
    }

    def record
      return unless root_segment
      return pretty_print

      VISITORS.each do |_, klass|
        visitor = klass.new(@vault, @scope)
        root_segment.accept(visitor)
        visitor.store_in_vault
      end

      # pretty_print if instant?
    end

    private

    def pretty_print
      visitor = HeimdallApm::Visitors::PrettyPrintVisitor.new(@scope)
      root_segment.accept(visitor)
      visitor.store_in_vault
    end

    # Send the request off to be stored
    def stop_request
      recorder.record(self) if recorder
    end

    # Are we finished with this transaction, i.e. no layers are left to be
    # popped out
    def finalized?
      @segments.empty?
    end
  end
end
