ENV['RACK_ENV'] ||= 'development'

require 'sinatra'
require 'json'
require 'simple_event_sourcing'
require 'sqlite3'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'bundler/setup'

Bundler.require(:default, Sinatra::Application.environment)

require 'arkency/command_bus'
require 'arkency/command_bus/alias'

require_relative './app/model/employee/employee_events'
require_relative './app/event_subscribers/employee_event_subscribers'
require_relative './app/model/employee/employee'

require_relative './app/model/employee_view'

require_relative './app/services/persistence/employee_repository'
#
require_relative './lib/service_provider'


require_relative './app/command_bus/commands'
require_relative './app/command_bus/command_handlers'
require_relative './app/command_bus/querys'
require_relative './app/command_bus/query_handlers'

Dir["#{File.dirname(__FILE__)}/app/services/**/*.rb"].each {|file| require file }

require_relative './lib/projection'

Dir["#{File.dirname(__FILE__)}/app/projections/*_projection.rb"].each {|file| require file }

require_relative './lib/base_controller'

Dir["#{File.dirname(__FILE__)}/app/controllers/**/*_controller.rb"].each {|file| require file }

require_relative './lib/json_api_app'
