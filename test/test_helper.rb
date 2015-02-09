require 'bundler/setup'
require 'simplecov'
require 'pry'
SimpleCov.configure do
  add_filter '/test/'
end
SimpleCov.start if ENV['COVERAGE']

require 'minitest/autorun'
require 'mongoid'

require File.expand_path("../../lib/mongoid-embedded_copy", __FILE__)

Mongoid.load!("#{File.dirname(__FILE__)}/mongoid.yml", "test")

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }

ActiveSupport::TestCase.test_order = :random

class BaseTest < ActiveSupport::TestCase
  def teardown
    Mongoid::Sessions.default.use('mongoid_embedded_copy_test').drop
  end
end

