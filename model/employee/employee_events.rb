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
