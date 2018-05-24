class ProjectorEmployeeEventSubscriber < SimpleEventSourcing::Events::EventSubscriber
  def is_subscribet_to?(_event)
    true
  end

  def handle(event)
    log = ServiceProvider::Container[:log]
    # db = SQLite3::Database.open "db/development.sqlite3"
    db = ActiveRecord::Base.connection
    log.debug "[SQLITE] Projecting Event: #{event.inspect}"
    case event
    when NewEmployeeIsHiredEvent
      log.debug "INSERT INTO employee_views(uuid, name, title , salary) VALUES ('#{event.aggregate_id}','#{event.name}','#{event.title}',#{event.salary.to_i})"
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
    log.debug "[ELASTICSEARCH] Projecting Event: #{event.inspect}"

    case event
    when NewEmployeeIsHiredEvent
      #client = Elasticsearch::Client.new url: 'http://elasticsearch:9200', log: true
      client = ServiceProvider::Container[:elasticsearch]
      #client.transport.reload_connections!
      #client.cluster.health
      #client.index index: 'employee', type: 'employee', id: event.aggregate_id, body: { name: event.name, title: event.title, salary: event.salary.to_i }
      client.save event
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
