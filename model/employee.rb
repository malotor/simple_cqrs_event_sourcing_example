require 'simple_event_sourcing'


class NewEmployeeIsHiredEvent < SimpleEventSourcing::Events::Event
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

end

class SalaryHasChangedEvent  < SimpleEventSourcing::Events::Event
  attr_reader  :new_salary

  def initialize(args)
    @new_salary = args[:new_salary]
    super(args)
  end

  def serialize
    super.merge("new_salary" => new_salary)
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

  def salary=(new_salary)
    apply_record_event SalaryHasChangedEvent , new_salary: new_salary
  end

  def self.create(name,title,salary)
    employee = new
    employee.apply_record_event  NewEmployeeIsHiredEvent,name: name,title: title, salary: salary
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

end
