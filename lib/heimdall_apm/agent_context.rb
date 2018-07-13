require 'set'

require 'heimdall_apm/vault'
require 'heimdall_apm/recorder'
require 'heimdall_apm/config'
require 'heimdall_apm/uri_matcher'

module HeimdallApm
  # Global context in which the agent is run. One context is assigned per
  # agent. It contains most of the part that are going to be accessed globally
  # by the rest of the monitoring.
  #
  class AgentContext
    # Global configuration object
    attr_writer :config

    def started!
      @started = true
    end

    def stopped!
      @started = false
    end

    def started?
      @started
    end

    def config
      @config ||= ::HeimdallApm::Config.new
    end

    def vault
      @vault ||= ::HeimdallApm::Vault.new(self)
    end

    def recorder
      @recorder ||= ::HeimdallApm::Recorder.new
    end

    def ignored_uris
      @ignored_uris ||= ::HeimdallApm::UriMatcher.new(config.value('ignore'))
    end

    def interactive?
      defined?(::Rails::Console) && $stdout.isatty && $stdin.isatty
    end
  end
end
