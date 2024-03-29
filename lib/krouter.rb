# frozen_string_literal: true

require 'rack'
require 'json'
require 'logger'
require 'securerandom'
require 'concurrent/map'
require 'kafka'
require 'dry/inflector'
require 'sentry-ruby'

require_relative 'krouter/version'
require_relative 'krouter/generate'

module Krouter
  class Krouter
    def initialize(kafka_ports: [ENV['KAFKA_URL']], domain: '', actions: [])
      @kafka = Kafka.new(kafka_ports, client_id: domain)
      @domain = domain
      @actions = actions
      @logger = Logger.new(STDOUT)

      Sentry.init do |config|
        config.dsn = ENV['SENTRY_DSN']
      end
    end

    def call
      log('Starting 🔥')
      p 'Listen topics:'
      puts routes.map { |key, value| "#{key} → #{value[:to]}" }

      consumer.each_message do |message|
        log("Received from #{message.topic}")
        params = parse(message)
        to = params[:to]
        meta = params.slice(:id, :help)
        begin
          data = params[:action].call(**params[:data])
          # deliver(meta, data, to)
          # log("Sended to: #{to}")
        rescue => e
          Sentry.capture_exception(e, tags: {from: message.topic, to: to})
        end
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

    def deliver(meta, data, to)
      message = meta.merge(data: data)
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
