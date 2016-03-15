$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

RACK_ENV = 'test' unless defined?(RACK_ENV)
if RACK_ENV != 'test'
  puts "You're not in the test environment, running specs will have potentially terrible side effects, rethink what you're doing"
  exit
end

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'

require 'distributed_lock'
Bundler.require(:default, RACK_ENV)

RSpec.configure do |conf|
  conf.color = true

  conf.before(:each) do
    Redis.new.flushdb
  end
end
