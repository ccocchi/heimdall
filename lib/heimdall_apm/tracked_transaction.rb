require 'heimdall_apm/visitors/request_metrics_visitor'
require 'heimdall_apm/visitors/pretty_print_visitor'

module HeimdallApm
  # A TrackedTransaction is a collection of segments.
  #
  class TrackedTransaction

    WEB_MODE = 1
    JOB_MODE = 2

    # First segment added to the transaction
    attr_reader :root_segment

    # Recorder used to process transaction data
    attr_reader :recorder

    # Scope of this transaction (controller routes / job id)
    attr_accessor :scope

    # Miscellaneous annotations made to the transaction. Must be a Hash.
    attr_reader :annotations

    def initialize(context)
      @context      = context
      @root_segment = nil
      @segments     = []
      @scope        = nil
      @stopped      = false
      @mode         = nil
      @annotations  = {}

      @recorder     = context.recorder
      @vault        = context.vault
    end

    def start_segment(segment)
      @root_segment = segment unless @root_segment
      @segments.push(segment)

      # TODO: maybe use a visitor to check that at the end of the request intead
      @mode ||=
        case segment.type
        when 'Controller' then WEB_MODE
        when 'Job'        then JOB_MODE
        else
          nil
        end

      segment.start
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
      # TODO: investigate on why mode can be nil sometimes
      return unless root_segment && @mode
      # TODO: doesn't feel like it should be done here
      return if annotations[:uri] && @context.ignored_uris.match?(annotations[:uri])

      VISITORS.each do |_, klass|
        visitor = klass.new(@vault, self)
        root_segment.accept(visitor)
        visitor.store_in_vault
      end
    end

    def stopped?
      @stopped
    end

    def annotate(hsh)
      @annotations.merge!(hsh)
    end

    # Allows InfluxDB's series name to be customize via annotations
    def custom_series_name
      annotations[:series_name]
    end

    def tags
      annotations[:tags]
    end

    def web?
      @mode == WEB_MODE
    end

    def job?
      @mode == JOB_MODE
    end

    private

    def pretty_print
      visitor = HeimdallApm::Visitors::PrettyPrintVisitor.new(@scope)
      root_segment.accept(visitor)
      visitor.store_in_vault
    end

    # Send the request off to be stored
    def stop_request
      @stopped = true
      recorder.record(self) if recorder
    end

    # Are we finished with this transaction, i.e. no layers are left to be
    # popped out
    def finalized?
      @segments.empty?
    end
  end
end
