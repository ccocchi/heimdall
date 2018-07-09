module HeimdallApm
  class Config
    def initialize
      @loaded = nil
      load_default_config
    end

    def value(key)
      # TODO: handle empty strings keys or boolean passed as strings
      @loaded && @settings[key]
    end
    alias_method :[], :value

    def has_key?(key)
      @settings.key?(key)
    end
    alias_method :key?, :has_key?

    private

    def load_default_config
      @settings = Rails.application.config_for(:heimdall_apm)
      @loaded   = true
    rescue
      # TODO: handle no configuration file found
    end
  end
end
