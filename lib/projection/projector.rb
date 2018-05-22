module Projector
  def self.included(o)
    o.extend(ClassMethods)
  end

  def apply_event(event)
    handler = self.class.event_mapping[event.class]
    self.instance_exec(event, &handler) if handler
  end

  module ClassMethods
    def event_mapping
      @event_mapping ||= {}
    end

    def project(*message_classes, &block)
      message_classes.each { |message_class| event_mapping[message_class] = block }
    end
  end

end

class EventsProjector

  def initialize(projections)
    @projections = projections
  end

  project NewEmployeeIsHiredEvent do |event|
    @projections.each do |p|
      p.new_employee_is_hired event
    end
  end

  project SalaryHasChangedEvent do |event|
    @projections.each do |p|
      p.salary_has_changed event
    end
  end

end
