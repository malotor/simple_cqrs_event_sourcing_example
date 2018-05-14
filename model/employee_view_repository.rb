require 'sqlite3'

class EmployeeViewRepository

  def initialize(connection)
    @connection = connection
  end

  def fetchById(id)

    stm = @connection.prepare "SELECT * FROM Employee where id=#{id}"
    rs = stm.execute

    rs.each do |row|
        puts row.join "\s"
    end


  end

end
