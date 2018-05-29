class ProjectorEmployeeEventSubscriber < SimpleEventSourcing::Events::EventSubscriber
  def is_subscribet_to?(_event)
    true
  end

  def handle(event)
    #DbProjection.new.project_event(event)
    #ElasticsearchProjection.new.project_event(event)
    Projector.project(event)
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
