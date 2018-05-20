require 'simple_event_sourcing'
require 'json'

class NewEmployeeIsHiredEvent < SimpleEventSourcing::Events::Event
  attr_reader :name, :title, :salary

  def initialize(args)
    @name = args[:name]
    @title = args[:title]
    @salary = args[:salary]
    super(args)
  end

  def serialize
    super.merge('name' => name, 'title' => title, 'salary' => salary)
  end
end

class SalaryHasChangedEvent < SimpleEventSourcing::Events::Event
  attr_reader :new_salary

  def initialize(args)
    @new_salary = args[:new_salary]
    super(args)
  end

  def serialize
    super.merge('new_salary' => new_salary)
  end
end

class ProjectorEmployeeEventSubscriber < SimpleEventSourcing::Events::EventSubscriber
  def is_subscribet_to?(_event)
    true
  end

  def handle(event)
    log = ServiceProvider::Container[:log]
    # db = SQLite3::Database.open "db/development.sqlite3"
    db = ActiveRecord::Base.connection
    log.debug "Projecting Event: #{event.inspect}"
    case event
    when NewEmployeeIsHiredEvent
      db.execute("INSERT INTO employee_views(uuid, name, title , salary) VALUES ('#{event.aggregate_id}','#{event.name}','#{event.title}',#{event.salary.to_i})")
    when SalaryHasChangedEvent
      db.execute("UPDATE employee_views SET salary = ?  WHERE uuid = '?'", [event.new_salary.to_i, event.aggregate_id])
    end
  end
end

class ProjectorElasticEmployeeEventSubscribe < SimpleEventSourcing::Events::EventSubscriber
  def is_subscribet_to?(_event)
    true
  end

  def handle(event)
    log = ServiceProvider::Container[:log]
    # db = SQLite3::Database.open "db/development.sqlite3"
    db = ActiveRecord::Base.connection
    log.debug "Projecting Event: #{event.inspect}"

    case event
    when NewEmployeeIsHiredEvent
      client = Elasticsearch::Client.new url: 'http://elasticsearch:9200', log: true
      client.transport.reload_connections!
      client.cluster.health
      client.index index: 'myindex', type: 'employee', id: event.aggregate_id, body: { name: event.name, title: event.title, salary: event.salary.to_i }

    when SalaryHasChangedEvent
      # db.execute("UPDATE employee_views SET salary = ?  WHERE uuid = '?'", [event.new_salary.to_i, event.aggregate_id])
    end
  end
end

class CongratulateEmployeeSubscriber < SimpleEventSourcing::Events::EventSubscriber
  def is_subscribet_to?(event)
    event.class == SalaryHasChangedEvent
  end

  def handle(event)
    # puts "Cogratulations for your new salary => #{event.new_salary}!!!!"
  end
end

class WelcomeEmployeeSubscriber < SimpleEventSourcing::Events::EventSubscriber
  def is_subscribet_to?(event)
    event.class == NewEmployeeIsHiredEvent
  end

  def handle(event)
    # puts "Wellcome  #{event.name}!!!!"
  end
end

class Employee
  include SimpleEventSourcing::AggregateRoot::Base

  private_class_method :new

  attr_reader :name, :title, :salary

  def promote(new_salary)
    apply_record_event SalaryHasChangedEvent, new_salary: new_salary
  end

  def self.generate_id(id)
    SimpleEventSourcing::Id::UUIDId.new id
  end

  def self.create(id, name, title, salary)
    employee = new
    employee.aggregate_id = SimpleEventSourcing::Id::UUIDId.new id
    employee.apply_record_event NewEmployeeIsHiredEvent, name: name, title: title, salary: salary
    employee
  end

  on NewEmployeeIsHiredEvent do |event|
    @name = event.name
    @title = event.title
    @salary = event.salary
  end

  on SalaryHasChangedEvent do |event|
    @salary = event.new_salary
  end

  def to_json
    { name: @name, title: @title, salary: @salary }.to_json
  end
end
