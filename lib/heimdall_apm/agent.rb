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
        context.logger.info 'Preventing agent to start in interactive mode'
        return
      end

      # if defined?(Sidekiq) && Sidekiq.server?
      #   # TODO: handle custom instrumentation disabling
      #   HeimdallApm.logger.info 'Preventing agent to start in sidekiq server'
      #   return
      # end

      start(options)
    end

    def start(options = {})
      return unless context.config.value('enabled')

      # TODO: use instruments manager
      if !defined?(Sidekiq) || !Sidekiq.server?
        require 'heimdall_apm/instruments/active_record'      if defined?(ActiveRecord)
        require 'heimdall_apm/instruments/action_controller'  if defined?(ActionController)
        require 'heimdall_apm/instruments/elasticsearch'      if defined?(Elasticsearch)
      end

      require 'heimdall_apm/instruments/sidekiq' if defined?(Sidekiq) && Sidekiq.server?

      if (options[:app])
        require 'heimdall_apm/instruments/middleware'
        # TODO: make the position configurable
        options[:app].config.middleware.insert_after Rack::Cors, HeimdallApm::Instruments::Middleware
        # XXX: useful for debugging maybe useful in the future
        # require 'heimdall_apm/instruments/middleware_detailed'
      end

      # TODO: handle platform/webserver that don't handle this correctly
      at_exit { stop }

      context.started!
      @background_thread = Thread.new { background_run }
    end

    def stop
      context.logger.info 'Stopping agent...'
      @stopped = true
      context.stopped!
      if @background_thread.alive?
        @background_thread.wakeup
        @background_thread.join
      end
    end

    private

    def background_run
      context.logger.info "Start background thread"
      reporting = ::HeimdallApm::Reporting.new(@context)
      next_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) + DEFAULT_PUSH_INTERVAL

      loop do
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        if @stopped
          # Commit data before stopping
          reporting.call
          break
        end

        if now < next_time
          remaining = next_time - now
          context.logger.debug { "Sleeping for #{remaining}" }
          sleep(remaining)
          next
        end

        reporting.call
        next_time = now + DEFAULT_PUSH_INTERVAL
      end
    rescue => e
      context.logger.error e.message
    end
  end
end
