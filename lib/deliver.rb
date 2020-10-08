# frozen_string_literal: true

require 'securerandom'

module Krouter
  class Deliver
    def initialize(kafka_ports: %w[kafka:9092], domain:)
      @kafka = Kafka.new(kafka_ports, client_id: domain)
    end

    def call(id: SecureRandom.uuid, data:, help:, to:)
      message = {
        id: id,
        data: data,
        help: help
      }
      @kafka.deliver_message(message.to_json, topic: to)
    end
  end
end
