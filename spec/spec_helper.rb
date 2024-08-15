# coding: utf-8

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'mongoid'
require 'database_cleaner-mongoid'
require 'mongoid-rspec'

require 'mongoid_money_field'

Money.default_currency = Money::Currency.new("RUB")

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ENV["MONGOID_ENV"] = "test"
Mongoid.load!("spec/support/mongoid.yml")

def mongoid3?
  defined?(Mongoid::VERSION) && Gem::Version.new(Mongoid::VERSION) >= Gem::Version.new('3.0.0.rc')
end

Mongoid.configure do |config|
  if mongoid3?
    ENV["MONGOID_ENV"] = "test"
    Mongoid.load!("spec/support/mongoid.yml")
  else
    config.master = Mongo::Connection.new.db('mongoid_money_field_test')
  end
end

RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner[:mongoid].strategy = [:deletion]
    #DatabaseCleaner.strategy = :truncation
  end
  config.after :each do
    DatabaseCleaner.clean
  end
  config.include Mongoid::Matchers
  config.mock_with :rspec
end
