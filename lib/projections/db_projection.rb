class DbProjection

  include Projection

  def initialize()
      @log = ServiceProvider::Container[:log]
      @db = ActiveRecord::Base.connection
  end

  # def project(event)
  #   self.send("project_#{event.class.name}",event)
  # end

  project NewEmployeeIsHiredEvent do |event|
    @log.debug "[DbProjection] Projecting Event: #{event.inspect}"
    @db.execute("INSERT INTO employee_views(uuid, name, title , salary) VALUES ('#{event.aggregate_id}','#{event.name}','#{event.title}',#{event.salary.to_i})")
  end

  project SalaryHasChangedEvent do |event|
    @log.debug "[DbProjection] Projecting Event: #{event.inspect}"
    # TODO
    #db = ActiveRecord::Base.connection
    #db.execute("UPDATE employee_views SET salary = ?  WHERE uuid = '?'", [event.new_salary.to_i, event.aggregate_id])
  end
end
