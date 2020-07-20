# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'kafka'

kafka = Kafka.new(['kafka:9092'], client_id: 'creator')

domain = 'vk.'

loop do
  mess = {
    id: rand(100),
    auth: { token: '123.123.123' },
    data: 'some data'
  }.to_json
  to = domain + 'items.create_template-create'
  kafka.deliver_message(mess, topic: to)

  mess = {
    id: rand(100),
    auth: { user: 'admin', pass: 'qwerty123' },
    data: { name: 'Some Name', data: 'Some Data' }
  }.to_json
  to = domain + 'items.templates-get'
  kafka.deliver_message(mess, topic: to)

  p 'Send requests'
  p '.....sleep 15 seconds'

  sleep 15
end
