class EmployeeView < ActiveRecord::Base
  validates_presence_of :uuid,:name,:title,:salary
end
