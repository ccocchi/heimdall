require 'rails/railtie'

module HeimdallApm
  class Railtie < Rails::Railtie
    initializer 'heimdall_apm.install' do |app|
      HeimdallApm::Agent.instance.install(app: app)
    end
  end
end
