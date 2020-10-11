# frozen_string_literal: true

require 'json'
require 'logger'
require 'kafka'
require 'dry/inflector'

require_relative 'krouter/version'
require_relative 'krouter/generate'

module Krouter
  class Krouter
    def initialize(kafka_ports: %w[kafka:9092], domain:, actions: [])
      @kafka = Kafka.new(kafka_ports, client_id: domain)
      @domain = domain
      @actions = actions
      @logger = Logger.new(STDOUT)
    end

    def call
      log('Waiting Kafka 😴 10 sec')
      sleep 10
      log('Starting 🔥')
      p 'Listen topics:'
      puts routes.map { |key, value| "#{key} → #{value[:to]}" }

      consumer.each_message do |message|
        log("Received from #{message.topic}")
        params = parse(message)
        response = params[:action].call(**params[:data])
        result = {
          id: params[:id],
          data: response,
          help: params[:help]
        }
        deliver(result, params[:to])
      end
    end

    private

    def parse(message)
      JSON.parse(message.value, symbolize_names: true)
          .merge(routes[message.topic])
          .slice(:id, :action, :to, :data, :help)
    end

    def consumer
      @consumer ||= begin
        consumer = @kafka.consumer(group_id: @domain)
        @routes.keys.each { |topic| consumer.subscribe(topic) }
        consumer
      end
    end

    def deliver(message, to)
      @kafka.deliver_message(message.to_json, topic: to)
    end

    def routes
      @routes ||= Generate.new.call(domain: @domain, actions: @actions)
    end

    def log(message)
      @logger.info(message)
    end
  end
end
