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
