# frozen_string_literal: true

require 'sinatra'
require 'redis'
require 'timeout'
require 'connection_pool'

redis = ConnectionPool.wrap(size: 5) { Redis.new(host: '127.0.0.1', port: 6379, db: 15) }

get '/' do
  'Hello world from pooled app!'
end

get '/create-deadlock' do
  redis.pipelined do
    1_000_000.times do
      redis.set('foo', 'bar')
    end
  end
  'Completed create-deadlock execution!'
end

get '/check-deadlock' do
  Timeout::timeout(3) do
    redis.ping
  end
  'Completed check-deadlock execution!'
end

