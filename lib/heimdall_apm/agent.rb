require 'heimdall_apm/agent_context'

module HeimdallApm
  # Main entry point for HeimdallApm. Only one instance is created per ruby
  # process, and it manages the lifecycle of the monitoring
  #
  class Agent
    @@instance = nil

    def self.instance(opts = {})
      @@instance ||= self.new(opts)
    end

    attr_reader :options

    attr_reader :context

    def initialize(opts)
      @options            = opts
      @context            = ::HeimdallApm::AgentContext.new
      @background_thread  = nil
    end

    def start
      @background_thread = Thread.new { }
    end

    def stop
      if @background_thread.alive?
        @background_thread.wakeup
        @background_thread.join
      end
    end
  end
end
