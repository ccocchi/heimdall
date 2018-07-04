require 'bundler'
# require 'bundler/inline'

# gemfile do
#   source "https://rubygems.org"
#   gem 'sinatra'
#   gem 'puma'
# end

require 'puma'
require 'sinatra'
require 'sinatra/cross_origin'
require 'influxdb'
require 'oj'

Oj.default_options = { mode: :compat }

module InfluxClient
  def self.init(env)
    @client = InfluxDB::Client.new("#{env}_metrics", time_precision: 'ms', retry: 0)
  end

  def self.instance
    @client
  end
end
InfluxClient.init(settings.environment)

configure {
  set :server, :puma
  set :bind, '0.0.0.0'
}

class MyApp < Sinatra::Base
  configure do
    disable :static
    enable  :cross_origin
  end

  before do
    content_type :json
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  options '*' do
    response.headers['Allow'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept'
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  end

  get '/transactions' do
    column = case params['sort_by']
    when 'slowest' then 'mean(total_time)'
    when 'consuming' then 'sum(total_time)'
    when 'throughput' then 'count(total_time)'
    end

    query   = "select #{column} from app where time >= now() - 10h group by endpoint"
    results = InfluxClient.instance.query(query)

    results.map! do |point|
      values = point['values'][0]
      value  = values['mean'] || values['sum']

      value  = (value * 1000).round if value
      value  ||= (values['count'] / 180.to_f).round(2)

      {
        endpoint: point['tags']['endpoint'],
        value: value
      }
    end

    Oj.dump(results)
  end
end

use MyApp
