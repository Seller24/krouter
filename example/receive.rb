# frozen_string_literal: true

require 'bundler/setup'
require 'concurrent/map'
require 'kafka'
require 'pry'
require 'json'

kafka = Kafka.new(['kafka:9092'], client_id: 'consumer')
consumer = kafka.consumer(group_id: 'consumer')

%w[
  vk.items.templates-receive
  vk.items.create_template-receive
].map { |topic| consumer.subscribe(topic) }

consumer.each_message do |message|
  pp JSON.parse(message.value).merge('from': message.topic)
end
