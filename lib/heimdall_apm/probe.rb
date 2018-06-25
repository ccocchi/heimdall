module HeimdallApm
  # Provides helpers for custom instrumentation of code
  #
  #   include Probe
  #   instrument('Elastic', 'profiles#search') do ... end
  #
  module Probe
    # Insruments block passed to the method into the current transaction.
    #
    # @param type Segment type (i.e 'ActiveRecord' or similar)
    # @param name Specific name for the segment
    #
    def instrument(type, name, opts = {})
      txn     = ::HeimdallApm::TransactionManager.current
      segment = ::HeimdallApm::Segment.new(type, name)
      txn.start_segment(segment)

      # TODO: maybe yield the segment here to have the block pass additional
      # informations
      yield
    ensure
      txn.stop_segment
    end
  end
end
