# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'kafka'

kafka = Kafka.new(['kafka:9092'], client_id: 'creator')
domain = 'vk'

sleep 20

loop do
  mess = {
    id: rand(100),
    data: { name: 'Sublime Name' },
    help: { id: 1 }
  }.to_json
  to = domain + '.items.create_template-create'
  kafka.deliver_message(mess, topic: to)

  # mess = {
  #   id: rand(100),
  #   data: { value: 'some value' },
  #   _: { class: 'SomeClass', args: { id: 3 } }
  # }.to_json
  # to = domain + '.items.templates-get'
  # kafka.deliver_message(mess, topic: to)

  p 'Sended requests'
  p '.....sleep 15 seconds'

  sleep 15
end
