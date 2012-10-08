# coding: utf-8

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'simplecov'
require 'mongoid'

require 'database_cleaner'

SimpleCov.start

require 'mongoid_money_field'

Money.default_currency = Money::Currency.new("RUB")

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def mongoid3?
  defined?(Mongoid::VERSION) && Gem::Version.new(Mongoid::VERSION) >= Gem::Version.new('3.0.0.rc')
end

Mongoid.configure do |config|
  if mongoid3?
    config.sessions[:default] = { :database => 'mongoid_money_field_test', :hosts => ['localhost:27017'] }
  else
    config.master = Mongo::Connection.new.db('mongoid_money_field_test')
  end
end

DatabaseCleaner.orm = "mongoid"

RSpec.configure do |config|
  config.before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.mock_with :rspec
end