class EmployeeRepository
  def initialize(event_store)
    @event_store = event_store
  end

  def save(employee)
    employee.events.each do |event|
      @event_store.commit event
      SimpleEventSourcing::Events::EventDispatcher.publish(event)
    end
  end

  def findById(id)
    history = @event_store.get_history id
    return Employee.create_from_history history
  end
end
