source 'https://rubygems.org'

gem 'sinatra', require: ['sinatra', 'sinatra/json']
gem 'sinatra-contrib'
gem 'sinatra-activerecord', require: 'sinatra/activerecord'
gem 'simple_event_sourcing', '~> 1.0.1'
gem 'bundler'
gem 'json'
gem "sqlite3"
gem 'arkency-command_bus', require: ['arkency/command_bus', 'arkency/command_bus/alias']
gem 'elasticsearch'
gem 'redis'
gem 'will_paginate'

group :development do
    gem 'pry'
    gem 'pry-byebug'
    gem 'thin'
    gem 'shotgun'
    gem 'tux'
    gem "rake"
    gem 'faker'
end

group :development,:test do
    gem 'rack-test'
    gem 'capybara'
    gem 'rspec'
    gem 'database_cleaner'
end
