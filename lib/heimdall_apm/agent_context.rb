require 'heimdall_apm/vault'
require 'heimdall_apm/recorder'

module HeimdallApm
  # Global context in which the agent is run. One context is assigned per
  # agent. It contains most of the part that are going to be accessed globally
  # by the rest of the monitoring.
  #
  class AgentContext
    # Global configuration object
    attr_writer :config

    def config
      @config ||= ::HeimdallApm::Config.new
    end

    def vault
      @vault ||= ::HeimdallApm::Vault.new(self)
    end

    def recorder
      @recorder ||= ::HeimdallApm::Recorder.new
    end
  end
end
