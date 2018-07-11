require 'heimdall_apm/agent_context'
require 'heimdall_apm/reporting'

module HeimdallApm
  # Main entry point for HeimdallApm. Only one instance is created per ruby
  # process, and it manages the lifecycle of the monitoring
  #
  class Agent
    DEFAULT_PUSH_INTERVAL = 60

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
      @stopped            = false
    end

    def install(options = {})
      context.config = ::HeimdallApm::Config.new

      if context.interactive?
        HeimdallApm.logger.info 'Preventing agent to start in interactive mode'
        return
      end

      if defined?(Sidekiq) && Sidekiq.server?
        # TODO: handle custom instrumentation disabling
        HeimdallApm.logger.info 'Preventing agent to start in sidekiq server'
        return
      end

      start(options)
    end

    def start(options = {})
      return unless context.config.value('enabled')

      # TODO: use instruments manager
      require 'heimdall_apm/instruments/active_record'      if defined?(ActiveRecord)
      require 'heimdall_apm/instruments/action_controller'  if defined?(ActionController)
      require 'heimdall_apm/instruments/elasticsearch'      if defined?(Elasticsearch)

      if (options[:app])
        require 'heimdall_apm/instruments/middleware'
        # TODO: make the position configurable
        options[:app].config.middleware.insert_after Rack::Cors, HeimdallApm::Instruments::Middleware
      end

      context.started!
      @background_thread = Thread.new { background_run }
    end

    def stop
      @stopped = true
      context.stopped!
      if @background_thread.alive?
        @background_thread.wakeup
        @background_thread.join
      end
    end

    private

    def background_run
      HeimdallApm.logger.info "Start background thread"
      reporting = ::HeimdallApm::Reporting.new(@context)
      next_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) + DEFAULT_PUSH_INTERVAL

      loop do
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        break if @stopped

        if now < next_time
          remaining = next_time - now
          HeimdallApm.logger.debug "Sleeping for #{remaining}"
          sleep(remaining)
          next
        end

        reporting.call
        next_time = now + DEFAULT_PUSH_INTERVAL
      end
    rescue => e
      HeimdallApm.logger.error e.message
    end
  end
end
