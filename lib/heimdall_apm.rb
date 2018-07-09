require 'heimdall_apm/version'
require 'heimdall_apm/segment'
require 'heimdall_apm/transaction_manager'
require 'heimdall_apm/probe'
require 'heimdall_apm/agent'
require 'heimdall_apm/railtie' if defined?(Rails)

require 'logger'

module HeimdallApm
  def self.logger
    @logger ||= Logger.new('log/heimdall_apm.log')
  end
end
