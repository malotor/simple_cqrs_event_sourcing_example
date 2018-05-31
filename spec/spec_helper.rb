ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'database_cleaner'

require File.expand_path '../app.rb', __dir__

module RSpecMixin
  include Rack::Test::Methods
  def app
    MyApp
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:suite) do; end

  config.before(:each) do
    DatabaseCleaner.start
    ServiceProvider::Container[:redis_client].flushall
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:example, :type => :elasticsearch) do
    ServiceProvider::Container[:elasticsearch].indices.delete index: '_all'
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
