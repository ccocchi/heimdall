module HeimdallApm
  # A TrackedTransaction is a collection of segments.
  #
  class TrackedTransaction

    # First segment added to the transaction
    attr_reader :root_segment

    # Recorder used to process transaction data
    attr_reader :recorder

    def initialize(vault)
      @vault        = vault
      @root_segment = nil
      @segments     = []
      @recorder     = vault.recorder
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

    private

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
