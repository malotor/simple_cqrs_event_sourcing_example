ENV['RACK_ENV'] = 'test'

require 'sinatra'
require 'rspec'
require 'rack/test'
require 'bundler/setup'
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

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)

    # redis.flushall
  end

  config.after(:suite) do
    # DatabaseCleaner.clean
    # ServiceProvider::Container[:elasticsearch].delete_by_query index: 'myindex', body: { query: { match_all: {} } }
  end

  config.before(:each) do
    DatabaseCleaner.start
    ServiceProvider::Container[:redis_client].flushall
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:example, :type => :elasticsearch) do
    ServiceProvider::Container[:elasticsearch].reset
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
