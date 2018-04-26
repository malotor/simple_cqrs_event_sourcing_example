require 'simple_event_sourcing'
require 'redis'
require 'json'


module RedisClient
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
    attr_accessor :host,:port,:mock

    def initialize
      @host ='localhost'
      @port = 6379
      @mock = false
    end
  end


  def self.get_client
    if @configuration.mock
      return RedisMock.new
    else
      return Redis.new(
        host: @configuration.host,
        port: @configuration.port
      )
    end
  end

end


class RedisEventStore < SimpleEventSourcing::Events::EventStore

  def initialize(client)
    @redis = client
  end

  def commit(event)

    stored_event = SimpleEventSourcing::Events::StoredEvent.new(
      aggregate_id: event.aggregate_id.to_s,
      occurred_on: Time.now.getlocal("+02:00").to_i,
      event_type: event.class.name,
      event_data: event.to_json
    )

    @redis.rpush(event.aggregate_id.to_s, stored_event.to_json )

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
    @entries[key] ||= []
    @entries[key] << value
  end
  def lrange(key,inf,max)
    @entries[key] ||= []
    return @entries[key]
  end
end
