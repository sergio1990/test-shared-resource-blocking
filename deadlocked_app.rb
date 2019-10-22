# frozen_string_literal: true

require 'sinatra'
require 'redis'

redis = Redis.new(host: '127.0.0.1', port: 6379, db: 15)

get '/' do
  'Hello world from deadlocked app!'
end

get '/create-deadlock' do
  redis.pipelined do
    100_000.times do
      redis.set('foo', 'bar')
    end
  end
  'Completed create-deadlock execution!'
end

get '/check-deadlock' do
  redis.ping
  'Completed check-deadlock execution!'
end
