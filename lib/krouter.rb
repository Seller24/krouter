# frozen_string_literal: true

require 'json'
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
    end

    def call
      p all_topics
      consumer.each_message do |message|
        p "Received from #{message.topic}"
        params = parse(message)
        response = params[:action].call(params[:auth], params[:data])
        result = {
          id: params[:id],
          success: response.success?,
          data: response.value_or(response.failure),
          _: params[:_]
        }
        deliver(result, params[:to])
      end
    end

    def create_topics
      topics = routes.map { |from, value| [from, value[:to]] }.flatten
      topics.each { |topic| @kafka.create_topic(topic) }
    end

    def all_topics
      routes.map { |key, value| { from: key, to: value[:to] } }
    end

    private

    def parse(message)
      JSON.parse(message.value, symbolize_names: true)
          .merge(routes[message.topic])
          .slice(:id, :action, :to, :auth, :data, :_)
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
  end
end
