class DbProjection

  include Projection
  include ServiceProvider::ContainerAware

  def getById(id)
    EmployeeView.find_by(uuid: id)
  end
  
  def getAll
    EmployeeView.all
  end

  project NewEmployeeIsHiredEvent do |event|
    log.debug "[DbProjection] Projecting Event: #{event.inspect}"
    db.execute("INSERT INTO employee_views(uuid, name, title , salary) VALUES ('#{event.aggregate_id}','#{event.name}','#{event.title}',#{event.salary.to_i})")
  end

  project SalaryHasChangedEvent do |event|
    log.debug "[DbProjection] Projecting Event: #{event.inspect}"
    # TODO
    #db = ActiveRecord::Base.connection
    #db.execute("UPDATE employee_views SET salary = ?  WHERE uuid = '?'", [event.new_salary.to_i, event.aggregate_id])
  end
end
