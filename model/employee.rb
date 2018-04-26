require 'simple_event_sourcing'
require_relative '../lib/redis_event_store'

class EmployeeStreamEvents < SimpleEventSourcing::AggregateRoot::History
  def get_aggregate_class
    Employee
  end
end

class SerializableEvent < SimpleEventSourcing::Events::Event

  def serialize
    {"aggregate_id" => aggregate_id, "occurred_on" => occurred_on }
  end

end

class NewEmployeeIsHiredEvent < SerializableEvent
  attr_reader :name, :title, :salary

  def initialize(args)
    @name = args[:name]
    @title = args[:title]
    @salary = args[:salary]
    super(args)
  end

  def serialize
    super.merge("name" => name, "title" => title , "salary" => salary )
  end

  def to_json(*a)
    serialize.to_json(*a)
  end

end

class SalaryHasChangedEvent  < SerializableEvent
  attr_reader  :new_salary

  def initialize(args)
    @new_salary = args[:new_salary]
    super(args)
  end

  def serialize
    super.merge("new_salary" => new_salary)
  end

  def to_json(*a)
    serialize.to_json(*a)
  end
end

class CongratulateEmployeeSubscriber < SimpleEventSourcing::Events::EventSubscriber

  def is_subscribet_to?(event)
    event.class == SalaryHasChangedEvent
  end

  def handle(event)
    puts "Cogratulations for your new salary => #{event.new_salary}!!!!"
  end

end

class WelcomeEmployeeSubscriber < SimpleEventSourcing::Events::EventSubscriber

  def is_subscribet_to?(event)
    event.class == NewEmployeeIsHiredEvent
  end

  def handle(event)
    puts "Wellcome  #{event.name}!!!!"
  end

end


class Employee

  include SimpleEventSourcing::AggregateRoot::Base

  attr_reader :name, :title, :salary

  def initialize(args = nil )
    super
    unless args.nil?
      apply_record_event  NewEmployeeIsHiredEvent , name: args[:name],  title: args[:title], salary: args[:salary]
    end
  end

  def salary=(new_salary)
    apply_record_event SalaryHasChangedEvent , new_salary: new_salary
  end

  def id
    aggregate_id.to_s
  end

  on NewEmployeeIsHiredEvent do |event|
    @name = event.name
    @title = event.title
    @salary = event.salary
  end

  on SalaryHasChangedEvent do |event|
    @salary = event.new_salary
  end

  # def save
  #
  #   client = RedisEventStore.new(RedisClient.get_client)
  #
  #   publish_events do |event|
  #     client.commit event
  #     SimpleEventSourcing::Events::EventDispatcher.publish(event)
  #   end
  #
  # end

end
