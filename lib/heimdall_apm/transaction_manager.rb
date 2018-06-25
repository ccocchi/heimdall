require 'heimdall/tracked_transaction'

module HeimdallApm
  # Handles the thread-local variable holding the current tracked transaction,
  # populating it the first time it is accessed.
  #
  class TransactionManager
    def self.current
      find || create
    end

    def self.find
      req = Thread.current[:heimdall_request]
      req
    end

    def self.create
      context = Agent.instance.context
      Thread.current[:heimdall_request] = ::HeimdallApm::TrackedTransaction.new(context)
    end
  end
end
