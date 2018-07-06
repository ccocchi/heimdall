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
      start(options)
    end

    def start(options = {})
      return unless context.config.value('enabled')

      @background_thread = Thread.new { background_run }

      # TODO: use instruments manager
      require 'heimdall_apm/instruments/active_record'      if defined?(ActiveRecord)
      require 'heimdall_apm/instruments/action_controller'  if defined?(ActionController)

      if (options[:app])
        require 'heimdall_apm/instruments/middleware'
        # TODO: make the position configurable
        options[:app].config.middleware.insert_after Rack::Cors, Heimdall::Middleware
      end
    end

    def stop
      @stopped = true
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
