require 'bundler'
require 'influxdb'

@client = InfluxDB::Client.new("development_metrics", time_precision: 'ms', retry: 0)

endpoints = [
  'Influence::V1::HomeController#app_init',
  'Influence::V1::HomeController#app_init',
  'Influence::V1::SearchesController#export',
  'Influence::V1::SearchesController#show',
  'Influence::V1::SearchesController#show',
  'Influence::V1::SearchesController#show',
  'Influence::V1::SearchesController#show',
  'Influence::V1::SearchesController#show',
  'Influence::V1::SearchesController#show',
  'Influence::V1::SearchesController#show',
  'V1::SessionsController#create',
  'Influence::V1::InfluenceProjectsController#show',
  'Influence::V1::PublicProfilesController#show',
  'Influence::V1::PublicProfilesController#show',
  'Influence::V1::PublicProfilesController#snas',
  'Influence::V1::PublicProfilesController#snas',
  'Influence::V1::PublicProfilesController#snas_stats',
  'Influence::V1::PublicProfilesController#snas_stats',
  'Influence::V1::PublicProfilesController#countries',
  'Influence::V1::PublicProfilesController#countries',
  'Influence::V1::PublicProfilesController#posts',
  'Influence::V1::PublicProfilesController#posts'
]

now = Time.now.to_f
interval = 3600 * 3 / 1000

i = 0
while i < 10
  j = 0
  points = []

  while (j < 100)
    endpoint = endpoints.sample

    time = now - rand(3) * interval + rand(500) / 1000.0

    ruby_time     = rand(50)
    elastic_time  = rand(500)
    sql_time      = rand(120)
    total_time = ruby_time + elastic_time + sql_time

    points << {
      series: 'app'.freeze,
      timestamp: (time * 1000).to_i,
      tags: { endpoint: endpoint },
      values: {
        ruby_time: ruby_time,
        elastic_time: elastic_time,
        sql_time: sql_time,
        total_time: total_time
      }
    }
    now -= interval
    j += 1
  end

  puts 'Writing points'
  @client.write_points(points)
  i += 1
end
