# frozen_string_literal: true

require 'bundler/setup'
require 'concurrent/map' # need for gem kafka
require 'kafka'
require 'pry'
require 'json'
require 'redis'

sleep 15

kafka = Kafka.new(['kafka:9092'], client_id: 'consumer')
redis = Redis.new(host: 'redis', port: 6379)
consumer = kafka.consumer(group_id: 'consumer')

%w[
  vk.items.templates-receive
  vk.items.create_template-receive
].each { |topic| consumer.subscribe(topic) }

def parse(mess)
  JSON.parse(mess, symbolize_names: true)
end

consumer.each_message do |message|
  result = parse(message.value).merge('from': message.topic)
  result[:data] = parse(redis.get(result[:data][:key]))
  pp result
end
