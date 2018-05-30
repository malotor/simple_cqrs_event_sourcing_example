require 'rubygems'
require "sinatra/activerecord/rake"
require 'faker'
require 'securerandom'

namespace :db do
  task  do
    require "./app"
  end
end


namespace :app do
  task  do
    require "./app"
  end

  desc "Create fixtures"
  task :create_fixtures  do
    require "./app"
    1000.times do
      ServiceProvider::Container[:employee_repository].save Employee.create(SecureRandom.uuid, Faker::Name.name.gsub(/\W/, '') , Faker::Job.title.gsub(/\W/, ''), Faker::Number.between(1000, 50000) )
    end
  end
end
