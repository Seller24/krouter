# frozen_string_literal: true

require 'json'
require 'logger'
require 'securerandom'
require 'concurrent/map'
require 'kafka'
require 'redis'
require 'dry/inflector'

require_relative 'krouter/version'
require_relative 'krouter/generate'

EXPIRATION_SEC = 7 * 86400 # Week

module Krouter
  class Krouter
    def initialize(kafka_ports: %w[kafka:9092], domain:, actions: [])
      @kafka = Kafka.new(kafka_ports, client_id: domain)
      @redis = Redis.new(host: 'redis', port: 6379)
      @domain = domain
      @actions = actions
      @logger = Logger.new(STDOUT)
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
        data = params[:action].call(**params[:data])
        deliver(meta, data, to)
        log("Sended to: #{to}")
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
      message = meta.merge(data: { key: create_link(data) })
      @kafka.deliver_message(message.to_json, topic: to)
    end

    def routes
      @routes ||= Generate.new.call(domain: @domain, actions: @actions)
    end

    def log(message)
      @logger.info(message)
    end

    def create_link(message)
      key = SecureRandom.uuid 
      @redis.set(key, message.to_json)
      @redis.expire(key, EXPIRATION_SEC)
      key
    end
  end
end
