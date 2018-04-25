require 'simple_event_sourcing'
require 'redis'
require 'json'

module RedisEventStore

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :host,:port

    def initialize
      @host ='localhost'
      @port = 6379
    end
  end

  class Client < SimpleEventSourcing::Events::EventStore

    def initialize
      @redis = Redis.new(
        host: RedisEventStore.configuration.host,
        port: RedisEventStore.configuration.port
      )
    end

    def commit(event)

      stored_event = SimpleEventSourcing::Events::StoredEvent.new(
        aggregate_id: event.aggregate_id.to_s,
        occurred_on: Time.now.getlocal("+02:00").to_i,
        event_type: event.class.name,
        event_data: event.to_json
      )

      @redis.rpush( event.aggregate_id, stored_event.to_json )

    end

  end

end
