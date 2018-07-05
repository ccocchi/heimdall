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

class ResultsParser
  def initialize(results)
    @results = results
  end

  # input: [{"name"=>"app", "tags"=>nil, "values"=>[{"time"=>"2018-07-05T09:45:00Z", "mean_elastic_time"=>292.4, "mean_ruby_time"=>12.4}]
  # output: [
  #  {"id"=>"mean_elastic_time", data: [{ "x": "2018-07-05T09:45:00Z", "y": 292.4}] },
  #  {"id"=>"mean_ruby_time", data: [{ "x": "2018-07-05T09:45:00Z", "y": 12.4}] }
  # ]
  #
  def to_graph_series
    series = Hash.new { |h, k| h[k] = [] }

    @results.each do |res|
      values = res['values']
      values.each do |vs|
        x = vs.delete('time'.freeze)
        vs.each do |id, value|
          value = value ? value.round(1) : 0
          series[id] << { x: x, y: value }
        end
      end
    end

    # Not needed for the moment (could be removed via the query direcly)
    series.delete('mean_total_time'.freeze)
    throughput = [{ id: 'throughput'.freeze, data: series.delete('count'.freeze) }]

    result = []
    series.each { |id, data| result << { id: id, data: data } }

    { throughput: throughput, times: result }
  end
end

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

    query   = "select #{column} from app where time >= now() - 3h group by endpoint"
    results = InfluxClient.instance.query(query)

    results.map! do |point|
      values = point['values'][0]
      value  = values['mean'] || values['sum']

      value  = value.round if value
      value  ||= (values['count'] / 180.to_f).round(2)

      {
        endpoint: point['tags']['endpoint'],
        value: value
      }
    end

    Oj.dump(results)
  end

  get '/transactions/details' do
    endpoint = params[:endpoint]
    return 400 unless endpoint

    query = "select mean(*), count(total_time) from app where endpoint = '#{endpoint}' AND time >= now() - 3h group by time(15m)"
    results = InfluxClient.instance.query(query)

    parser = ResultsParser.new(results)
    Oj.dump(parser.to_graph_series)
  end
end

use MyApp
