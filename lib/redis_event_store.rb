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
    attr_accessor :host,:port,:client

    def initialize
      @host ='localhost'
      @port = 6379
      @client = nil
    end
  end


  class Client < SimpleEventSourcing::Events::EventStore

    def initialize(client = nil)
      if  RedisEventStore.configuration.client.nil?
        @redis = Redis.new(
          host: RedisEventStore.configuration.host,
          port: RedisEventStore.configuration.port
        )
      else
        @redis = RedisEventStore.configuration.client
      end
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

    def get_history(aggregate_id)
      stored_events_json = @redis.lrange( aggregate_id, 0, -1 )
      history = SimpleEventSourcing::AggregateRoot::History.new(aggregate_id)
      stored_events_json.each do |stored_event_json|
        stored_event =  SimpleEventSourcing::Events::StoredEvent.create_from_json stored_event_json
        event = Object.const_get(stored_event.event_type)
        args = JSON.parse(stored_event.event_data)
        args.keys.each do |key|
          args[(key.to_sym rescue key) || key] = args.delete(key)
        end
        recovered_event = event.new(args)
        history << recovered_event
      end
      history
    end

  end

  class RedisMock
    attr_reader :entries

    def initialize
      @entries = Hash.new()
    end
    def rpush(key, value)
      puts "#{key} => #{value}"
      @entries[key] ||= []
      @entries[key] << value
    end
    def lrange(key,inf,max)
      return @entries[key]
    end
  end
end
