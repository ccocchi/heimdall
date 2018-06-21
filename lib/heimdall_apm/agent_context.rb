module HeimdallApm
  # Global context in which the agent is run. One context is assigned per
  # agent. It contains most of the part that are going to be accessed globally
  # by the rest of the monitoring.
  #
  class AgentContext
    def vault
      @vault ||= ::HeimdallApm::Vault.new
    end

    def recorder
      @recorder ||= ::HeimdallApm::Recorder.new
    end
  end
end
